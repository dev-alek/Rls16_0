&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-disc


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE hrtt-dis-card NO-UNDO LIKE ub.dis-card.
DEFINE TEMP-TABLE htt-dis-card NO-UNDO LIKE ub.dis-card.
DEFINE TEMP-TABLE rtt-dis-card NO-UNDO LIKE ub.dis-card.
DEFINE BUFFER r_dis-host FOR ub.dis-host.
DEFINE BUFFER r_dis-obj FOR ub.dis-obj.
DEFINE BUFFER r_shop FOR ub.shop.
DEFINE BUFFER r_sysconf FOR ub.sysconf.
DEFINE TEMP-TABLE tt-dis-card NO-UNDO LIKE ub.dis-card.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-disc
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Итоги по дисконтным картам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/05
Author: Bakhtadze Natalya
Creation date: 12/08/05

Author: Черных В.Г.
Created: 19/01/99

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter inp-d-card like ub.dis-card.d-card no-undo .
define input parameter p-legacy as logical no-undo .
define input parameter p-subsid as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Итоги по дисконтным картам" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ gbl/1bascur.i  }
{ gbl/dct-algo.i }
{ gbl/getcntxt.i def }
{ nws/lib-nws.i }
{ ref/dc-smart.i }
/* Local Variable Definitions ---                                       */

define variable LogRes as logical no-undo .
define buffer for-dis for ub.dis-obj.
/*запоминает max возможную сумму платежа по объекту*/
define variable max-pay-sum like ub.dis-obj.pay-tot-base.
define variable TotalPayPrim as decimal no-undo.
define variable CreditSumPrim as decimal no-undo.
define variable TotalSumPrim as decimal no-undo.
define variable DiscSumPrim as decimal no-undo.
define variable NettoSumPrim as decimal no-undo.
define variable MustPayPrim as decimal no-undo.
define variable SaldosumPrim as decimal no-undo.
define variable RestLimitPrim as decimal no-undo.
define variable LimitSumPrim as decimal no-undo.
define variable globalcard as logical no-undo.
define variable sort-column-name as character no-undo .
define variable rid as recid no-undo.
define variable glob-val as logical no-undo init yes.
define variable v-glob-curr-code like ub.currency.curr-code no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-first as logical no-undo init yes.
define variable vhb as character no-undo .
define variable vhr as character NO-UNDO .
define variable vob as character no-undo .
define variable vor as character no-undo .
DEFINE VARIABLE v-ok-dis-obj AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ok-rdis-obj AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ok-dis-host AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ok-rdis-host AS CHARACTER NO-UNDO.


define buffer current_dis-card for ub.dis-card.
&scop view-hide-list1 ~
    if RS-gen-PRivate = 1 then do:                    ~
      hide ~{&list-1~} in frame ~{&frame-name~}.      ~
      display selectcurr with frame ~{&frame-name~}.  ~
    end.                                              ~
    else do:                                          ~
      display ~{&List-1~} with frame ~{&frame-name~}. ~
    end

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-disc
&Scoped-define BROWSE-NAME BR-dis-host-b

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES htt-dis-card ub.dis-host ub.sysconf hrtt-dis-card ~
r_dis-host r_sysconf tt-dis-card ub.dis-obj ub.shop rtt-dis-card r_dis-obj r_shop

/* Definitions for BROWSE BR-dis-host-b                                 */
&Scoped-define FIELDS-IN-QUERY-BR-dis-host-b dc-smart_is-this-correct( INPUT ub.dis-host.dt-code ,INPUT {&TABLE_dis-host} ,INPUT v-cntxt-db-num ,INPUT htt-dis-card.TYPE ,INPUT htt-dis-card.emitent-host-code ,INPUT {&cmp} ,INPUT ub.dis-host.host-code ,INPUT htt-dis-card.d-card) @ v-ok-dis-host ub.dis-host.host-code dct-algo-get-sum-id-from-dt-code(INPUT ub.dis-host.dt-code) @ vhb ub.dis-host.gds-tot-base ub.dis-host.gds-dis-base ub.dis-host.gds-tot-base - ub.dis-host.gds-dis-base ub.dis-host.num-chk ub.dis-host.gds-tot-base - ub.dis-host.gds-dis-base - ub.dis-host.ub.pay-tot-base ub.dis-host.d-card
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dis-host-b ub.dis-host.num-chk
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-dis-host-b ub.dis-host
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-dis-host-b ub.dis-host
&Scoped-define SELF-NAME BR-dis-host-b
&Scoped-define QUERY-STRING-BR-dis-host-b FOR EACH htt-dis-card NO-LOCK, ~
             FIRST ub.dis-host WHERE TRUE /* Join to tt-dis-card incomplete */ NO-LOCK, ~
             EACH ub.sysconf OF ub.dis-host NO-LOCK
&Scoped-define OPEN-QUERY-BR-dis-host-b OPEN QUERY {&SELF-NAME} FOR EACH htt-dis-card NO-LOCK, ~
             FIRST ub.dis-host WHERE TRUE /* Join to tt-dis-card incomplete */ NO-LOCK, ~
             EACH ub.sysconf OF ub.dis-host NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-dis-host-b htt-dis-card dis-host sysconf
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dis-host-b htt-dis-card
&Scoped-define SECOND-TABLE-IN-QUERY-BR-dis-host-b dis-host
&Scoped-define THIRD-TABLE-IN-QUERY-BR-dis-host-b sysconf


/* Definitions for BROWSE BR-dis-host-r                                 */
&Scoped-define FIELDS-IN-QUERY-BR-dis-host-r dc-smart_is-this-correct( INPUT r_dis-host.dt-code ,INPUT {&TABLE_dis-host} ,INPUT v-cntxt-db-num ,INPUT hrtt-dis-card.TYPE ,INPUT hrtt-dis-card.emitent-host-code ,INPUT {&cmp} ,INPUT r_dis-host.host-code ,INPUT hrtt-dis-card.d-card) @ v-ok-rdis-host r_dis-host.host-code dct-algo-get-sum-id-from-dt-code(INPUT r_dis-host.dt-code) @ vhr r_dis-host.gds-tot-rubl r_dis-host.gds-dis-rubl r_dis-host.gds-tot-rubl - r_dis-host.gds-dis-rubl r_dis-host.num-chk r_dis-host.gds-tot-rubl - r_dis-host.gds-dis-rubl - r_dis-host.pay-tot-rubl r_dis-host.d-card
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dis-host-r r_dis-host.num-chk
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-dis-host-r r_dis-host
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-dis-host-r r_dis-host
&Scoped-define SELF-NAME BR-dis-host-r
&Scoped-define QUERY-STRING-BR-dis-host-r FOR EACH hrtt-dis-card NO-LOCK, ~
             FIRST r_dis-host WHERE TRUE /* Join to hrtt-dis-card incomplete */ NO-LOCK, ~
             EACH r_sysconf OF r_dis-host NO-LOCK
&Scoped-define OPEN-QUERY-BR-dis-host-r OPEN QUERY {&SELF-NAME} FOR EACH hrtt-dis-card NO-LOCK, ~
             FIRST r_dis-host WHERE TRUE /* Join to hrtt-dis-card incomplete */ NO-LOCK, ~
             EACH r_sysconf OF r_dis-host NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-dis-host-r hrtt-dis-card r_dis-host ~
r_sysconf
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dis-host-r hrtt-dis-card
&Scoped-define SECOND-TABLE-IN-QUERY-BR-dis-host-r r_dis-host
&Scoped-define THIRD-TABLE-IN-QUERY-BR-dis-host-r r_sysconf


/* Definitions for BROWSE BR-dis-obj-b                                  */
&Scoped-define FIELDS-IN-QUERY-BR-dis-obj-b dc-smart_is-this-correct( INPUT ub.dis-obj.dt-code ,INPUT {&TABLE_dis-obj} ,INPUT v-cntxt-db-num ,INPUT tt-dis-card.TYPE ,INPUT tt-dis-card.emitent-host-code ,INPUT ub.dis-obj.obj-type ,INPUT dub.is-obj.obj-code ,INPUT tt-dis-card.d-card) @ v-ok-dis-obj ub.dis-obj.obj-code dct-algo-get-sum-id-from-dt-code(INPUT ub.dis-obj.dt-code) @ vob ub.dis-obj.gds-tot-base ub.dis-obj.gds-dis-base ub.dis-obj.gds-tot-base + ub.dis-obj.sum-tot-base - ub.dis-obj.gds-dis-base - ub.dis-obj.sum-dis-base ub.dis-obj.num-chk ub.dis-obj.gds-tot-base - ub.dis-obj.gds-dis-base + ub.dis-obj.sum-tot-base - ub.dis-obj.sum-dis-base - ub.dis-obj.pay-tot-base ub.dis-obj.d-card
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dis-obj-b ub.dis-obj.num-chk
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-dis-obj-b ub.dis-obj
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-dis-obj-b ub.dis-obj
&Scoped-define SELF-NAME BR-dis-obj-b
&Scoped-define QUERY-STRING-BR-dis-obj-b FOR EACH tt-dis-card NO-LOCK, ~
             FIRST ub.dis-obj WHERE TRUE /* Join to tt-dis-card incomplete */ NO-LOCK, ~
             EACH ub.shop OF ub.dis-obj NO-LOCK
&Scoped-define OPEN-QUERY-BR-dis-obj-b OPEN QUERY {&SELF-NAME} FOR EACH tt-dis-card NO-LOCK, ~
             FIRST ub.dis-obj WHERE TRUE /* Join to tt-dis-card incomplete */ NO-LOCK, ~
             EACH ub.shop OF ub.dis-obj NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-dis-obj-b tt-dis-card ub.dis-obj ub.shop
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dis-obj-b tt-dis-card
&Scoped-define SECOND-TABLE-IN-QUERY-BR-dis-obj-b ub.dis-obj
&Scoped-define THIRD-TABLE-IN-QUERY-BR-dis-obj-b shop


/* Definitions for BROWSE BR-dis-obj-r                                  */
&Scoped-define FIELDS-IN-QUERY-BR-dis-obj-r dc-smart_is-this-correct( INPUT r_dis-obj.dt-code ,INPUT {&TABLE_dis-obj} ,INPUT v-cntxt-db-num ,INPUT rtt-dis-card.TYPE ,INPUT rtt-dis-card.emitent-host-code ,INPUT r_dis-obj.obj-type ,INPUT r_dis-obj.obj-code ,INPUT rtt-dis-card.d-card) @ v-ok-rdis-obj r_dis-obj.obj-code dct-algo-get-sum-id-from-dt-code(INPUT r_dis-obj.dt-code) @ vor r_dis-obj.gds-tot-rubl r_dis-obj.gds-dis-rubl r_dis-obj.gds-tot-rubl + r_dis-obj.sum-tot-rubl - r_dis-obj.gds-dis-rubl - r_dis-obj.sum-dis-rubl r_dis-obj.num-chk r_dis-obj.gds-tot-rubl + r_dis-obj.sum-tot-rubl - r_dis-obj.gds-dis-rubl - r_dis-obj.sum-dis-rubl - r_dis-obj.pay-tot-rubl r_dis-obj.d-card
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dis-obj-r r_dis-obj.num-chk
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-dis-obj-r r_dis-obj
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-dis-obj-r r_dis-obj
&Scoped-define SELF-NAME BR-dis-obj-r
&Scoped-define QUERY-STRING-BR-dis-obj-r FOR EACH rtt-dis-card NO-LOCK, ~
             FIRST r_dis-obj WHERE TRUE /* Join to rtt-dis-card incomplete */ NO-LOCK, ~
             EACH r_shop OF r_dis-obj NO-LOCK
&Scoped-define OPEN-QUERY-BR-dis-obj-r OPEN QUERY {&SELF-NAME} FOR EACH rtt-dis-card NO-LOCK, ~
             FIRST r_dis-obj WHERE TRUE /* Join to rtt-dis-card incomplete */ NO-LOCK, ~
             EACH r_shop OF r_dis-obj NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-dis-obj-r rtt-dis-card r_dis-obj r_shop
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dis-obj-r rtt-dis-card
&Scoped-define SECOND-TABLE-IN-QUERY-BR-dis-obj-r r_dis-obj
&Scoped-define THIRD-TABLE-IN-QUERY-BR-dis-obj-r r_shop


/* Definitions for DIALOG-BOX d-disc                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-disc ~
    ~{&OPEN-QUERY-BR-dis-host-b}~
    ~{&OPEN-QUERY-BR-dis-host-r}~
    ~{&OPEN-QUERY-BR-dis-obj-b}~
    ~{&OPEN-QUERY-BR-dis-obj-r}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel B-chk B-print b-history B-help ~
RECT-1 T-legacy T-subsid SelectCurr Rs-gen-private rs-host-obj BR-dis-obj-r ~
BR-dis-obj-b BR-dis-host-r TotalSum lNumCard NumCard NumChk DiscSum ~
NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum
&Scoped-Define DISPLAYED-OBJECTS T-legacy T-subsid SelectCurr ~
Rs-gen-private rs-host-obj f-smart-info-sums val-title TotalSum lNumCard ~
NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum ~
RestLimit LimitSum

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 SelectCurr TotalSum NumCard NumChk DiscSum NettoSum ~
SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-chk
     LABEL "Че&ки"
     SIZE 10 BY 1.

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1.

DEFINE BUTTON b-history
     LABEL "Ис&тория"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_Cost
     LABEL "&Учет"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE CreditSum AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .67
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE DiscSum AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .67
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE f-smart-info-sums AS CHARACTER FORMAT "X(256)":U INITIAL "Нет маршрутизации:данные м.б. некорректны!!!!"
      VIEW-AS TEXT
     SIZE 46.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE LimitSum AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .67
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE lNumCard AS CHARACTER FORMAT "X(256)":U INITIAL "Карт с учетом перевыпуска"
      VIEW-AS TEXT
     SIZE 27.3 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE Mustpay AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .67
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE NettoSum AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .7
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE NumCard AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 6.8 BY .67
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE NumChk AS INTEGER FORMAT "->>>>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 8 BY .67
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE RestLimit AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .67
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE SaldoSum AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .67
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE TotalPay AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .7
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE TotalSum AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .67
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE val-title AS CHARACTER FORMAT "X(256)":U INITIAL "ИТОГО по карте (данные офиса)"
      VIEW-AS TEXT
     SIZE 29.4 BY .67 NO-UNDO.

DEFINE VARIABLE Rs-gen-private AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Общие", 0,
"Частные", 1
     SIZE 18 BY .67 NO-UNDO.

DEFINE VARIABLE rs-host-obj AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Объекты", "obj",
"Фирмы", "host"
     SIZE 18 BY .67 NO-UNDO.

DEFINE VARIABLE SelectCurr AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "abbr_rubli_firstshift", "rubl",
"Баз.вал.", "base"
     SIZE 25.8 BY .63 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 7.33
     BGCOLOR 8 FGCOLOR 0 .

DEFINE VARIABLE T-legacy AS LOGICAL INITIAL no
     LABEL "Перевыпуск"
     VIEW-AS TOGGLE-BOX
     SIZE 12.5 BY .97 TOOLTIP "С учетом перевыпуска карт" NO-UNDO.

DEFINE VARIABLE T-subsid AS LOGICAL INITIAL no
     LABEL "Дополнит-ные"
     VIEW-AS TOGGLE-BOX
     SIZE 15.5 BY .97 TOOLTIP "С учетом дополнительных карт" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-dis-host-b FOR
      htt-dis-card,
      ub.dis-host,
      ub.sysconf SCROLLING.

DEFINE QUERY BR-dis-host-r FOR
      hrtt-dis-card,
      r_dis-host,
      r_sysconf SCROLLING.

DEFINE QUERY BR-dis-obj-b FOR
      tt-dis-card,
      ub.dis-obj,
      ub.shop SCROLLING.

DEFINE QUERY BR-dis-obj-r FOR
      rtt-dis-card,
      r_dis-obj,
      r_shop SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-dis-host-b
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dis-host-b d-disc _FREEFORM
  QUERY BR-dis-host-b NO-LOCK DISPLAY
      dc-smart_is-this-correct( INPUT dis-host.dt-code
                      ,INPUT {&TABLE_dis-host}
                      ,INPUT v-cntxt-db-num
                      ,INPUT htt-dis-card.TYPE
                       ,INPUT htt-dis-card.emitent-host-code
                       ,INPUT {&cmp}
                       ,INPUT dis-host.host-code
                       ,INPUT htt-dis-card.d-card)

      @ v-ok-dis-host COLUMN-LABEL "OK" FORMAT "X(1)"
      dis-host.host-code COLUMN-LABEL "Фирма" FORMAT "99999"
      dct-algo-get-sum-id-from-dt-code(INPUT dis-host.dt-code) @ vhb COLUMN-LABEL "ЧАСТНЫЙ ИТОГ" FORMAT "X(32)"
      dis-host.gds-tot-base COLUMN-LABEL "Сумма товарная" format "->>,>>>,>>>,>>>,>>9.99"
      dis-host.gds-dis-base COLUMN-LABEL "Скидка товарная" format "->>,>>>,>>>,>>>,>>9.99"
      dis-host.gds-tot-base  - dis-host.gds-dis-base COLUMN-LABEL "Сумма нетто" FORMAT "->>,>>>,>>>,>>>,>>>.<<"
      dis-host.num-chk COLUMN-LABEL "Число!чеков" format "->>>>>9"
      dis-host.gds-tot-base  - dis-host.gds-dis-base  - dis-host.pay-tot-base COLUMN-LABEL "Сумма в кредит" FORMAT "->>,>>>,>>>,>>>,>>>.<<"
      dis-host.d-card COLUMN-LABEL "Дисконтная карта" format "X(16)"
   ENABLE
      dis-host.num-chk
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.63
         BGCOLOR 15
         TITLE BGCOLOR 15 "В баз. вал.".

DEFINE BROWSE BR-dis-host-r
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dis-host-r d-disc _FREEFORM
  QUERY BR-dis-host-r NO-LOCK DISPLAY
      dc-smart_is-this-correct( INPUT r_dis-host.dt-code
                      ,INPUT {&TABLE_dis-host}
                      ,INPUT v-cntxt-db-num
                      ,INPUT hrtt-dis-card.TYPE
                       ,INPUT hrtt-dis-card.emitent-host-code
                       ,INPUT {&cmp}
                       ,INPUT r_dis-host.host-code
                       ,INPUT hrtt-dis-card.d-card)

      @ v-ok-rdis-host COLUMN-LABEL "OK" FORMAT "X(1)"
      r_dis-host.host-code COLUMN-LABEL "Фирма" FORMAT "99999"
      dct-algo-get-sum-id-from-dt-code(INPUT r_dis-host.dt-code) @ vhr COLUMN-LABEL "ЧАСТНЫЙ ИТОГ" FORMAT "X(32)"
      r_dis-host.gds-tot-rubl COLUMN-LABEL "Сумма товарная" format "->>,>>>,>>>,>>>,>>9.99"
      r_dis-host.gds-dis-rubl COLUMN-LABEL "Скидка товарная" format "->>,>>>,>>>,>>>,>>9.99"
      r_dis-host.gds-tot-rubl  - r_dis-host.gds-dis-rubl COLUMN-LABEL "Сумма нетто" FORMAT "->>,>>>,>>>,>>>,>>>.<<"
      r_dis-host.num-chk COLUMN-LABEL "Число!чеков" format "->>>>>9"
      r_dis-host.gds-tot-rubl - r_dis-host.gds-dis-rubl - r_dis-host.pay-tot-rubl COLUMN-LABEL "Сумма в кредит" FORMAT "->>,>>>,>>>,>>>,>>>.<<"
      r_dis-host.d-card COLUMN-LABEL "Дисконтная карта" format "X(16)"
  ENABLE
      r_dis-host.num-chk
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.63
         BGCOLOR 15 FGCOLOR 0
         TITLE BGCOLOR 15 FGCOLOR 0 "В abbr_rublyah".

DEFINE BROWSE BR-dis-obj-b
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dis-obj-b d-disc _FREEFORM
  QUERY BR-dis-obj-b NO-LOCK DISPLAY
      dc-smart_is-this-correct( INPUT ub.dis-obj.dt-code
                      ,INPUT {&TABLE_dis-obj}
                      ,INPUT v-cntxt-db-num
                      ,INPUT tt-dis-card.TYPE
                       ,INPUT tt-dis-card.emitent-host-code
                       ,INPUT ub.dis-obj.obj-type
                       ,INPUT ub.dis-obj.obj-code
                       ,INPUT tt-dis-card.d-card)

      @ v-ok-dis-obj COLUMN-LABEL "OK" FORMAT "X(1)"
      ub.dis-obj.obj-code COLUMN-LABEL "Магазин" FORMAT ">>>>9"
      dct-algo-get-sum-id-from-dt-code(INPUT ub.dis-obj.dt-code) @ vob COLUMN-LABEL "ЧАСТНЫЙ ИТОГ" FORMAT "X(32)"
      ub.dis-obj.gds-tot-base COLUMN-LABEL "Сумма товарная"  format "->>,>>>,>>>,>>>,>>9.99"
      ub.dis-obj.gds-dis-base COLUMN-LABEL "Скидка товарная" format "->>,>>>,>>>,>>>,>>9.99"
      ub.dis-obj.gds-tot-base + ub.dis-obj.sum-tot-base - ub.dis-obj.gds-dis-base - ub.dis-obj.sum-dis-base COLUMN-LABEL "Сумма нетто" FORMAT "->>,>>>,>>>,>>>,>>9.99"
      ub.dis-obj.num-chk COLUMN-LABEL "Число!чеков" format "->>>>>9"
      ub.dis-obj.gds-tot-base - ub.dis-obj.gds-dis-base + ub.dis-obj.sum-tot-base - ub.dis-obj.sum-dis-base - ub.dis-obj.pay-tot-base COLUMN-LABEL "Сумма в кредит" FORMAT "->>,>>>,>>>,>>>,>>9.99"
      ub.dis-obj.d-card COLUMN-LABEL "Дисконтная карта" format "X(16)"
   ENABLE
      ub.dis-obj.num-chk
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.63
         BGCOLOR 15 FGCOLOR 0
         TITLE BGCOLOR 15 FGCOLOR 0 "В баз. вал.".

DEFINE BROWSE BR-dis-obj-r
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dis-obj-r d-disc _FREEFORM
  QUERY BR-dis-obj-r NO-LOCK DISPLAY
      dc-smart_is-this-correct( INPUT r_dis-obj.dt-code
                      ,INPUT {&TABLE_dis-obj}
                      ,INPUT v-cntxt-db-num
                      ,INPUT rtt-dis-card.TYPE
                      ,INPUT rtt-dis-card.emitent-host-code
                      ,INPUT r_dis-obj.obj-type
                      ,INPUT r_dis-obj.obj-code
                      ,INPUT rtt-dis-card.d-card)
      @ v-ok-rdis-obj COLUMN-LABEL "OK" FORMAT "X(1)"
      r_dis-obj.obj-code COLUMN-LABEL "Магазин" FORMAT "99999"
      dct-algo-get-sum-id-from-dt-code(INPUT r_dis-obj.dt-code) @ vor COLUMN-LABEL "ЧАСТНЫЙ ИТОГ" FORMAT "X(32)"
      r_dis-obj.gds-tot-rubl COLUMN-LABEL "Сумма товарная" format "->>,>>>,>>>,>>>,>>9.99"
      r_dis-obj.gds-dis-rubl COLUMN-LABEL "Скидка товарная" format "->>,>>>,>>>,>>>,>>9.99"
      r_dis-obj.gds-tot-rubl + r_dis-obj.sum-tot-rubl - r_dis-obj.gds-dis-rubl - r_dis-obj.sum-dis-rubl COLUMN-LABEL "Сумма нетто" FORMAT "->>,>>>,>>>,>>>,>>>.<<"
      r_dis-obj.num-chk COLUMN-LABEL "Число!чеков" format "->>>>>9"
      r_dis-obj.gds-tot-rubl + r_dis-obj.sum-tot-rubl - r_dis-obj.gds-dis-rubl - r_dis-obj.sum-dis-rubl - r_dis-obj.pay-tot-rubl COLUMN-LABEL "Сумма в кредит" FORMAT "->>,>>>,>>>,>>>,>>>.<<"
      r_dis-obj.d-card COLUMN-LABEL "Дисконтная карта" format "X(16)"
      ENABLE
      r_dis-obj.num-chk
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.63
         BGCOLOR 15 FGCOLOR 0
         TITLE BGCOLOR 15 FGCOLOR 0 "В abbr_rublyah".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-disc
     Btn_Cancel AT ROW 1 COL 1
     B-chk AT ROW 1 COL 21
     Btn_Cost AT ROW 1 COL 31
     B-print AT ROW 1 COL 89
     b-history AT ROW 1 COL 92
     B-help AT ROW 1 COL 95
     T-legacy AT ROW 2.33 COL 71
     T-subsid AT ROW 2.33 COL 84
     SelectCurr AT ROW 2.5 COL 1 NO-LABEL
     Rs-gen-private AT ROW 2.5 COL 32 NO-LABEL
     rs-host-obj AT ROW 2.5 COL 53 NO-LABEL
     BR-dis-obj-r AT ROW 3.5 COL 1
     BR-dis-obj-b AT ROW 3.5 COL 1
     BR-dis-host-r AT ROW 3.5 COL 1
     BR-dis-host-b AT ROW 3.5 COL 1
     f-smart-info-sums AT ROW 12.2 COL 46.5 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     val-title AT ROW 12.33 COL 4 COLON-ALIGNED NO-LABEL
     TotalSum AT ROW 13.13 COL 38.5 RIGHT-ALIGNED NO-LABEL
     lNumCard AT ROW 13.87 COL 60.9 COLON-ALIGNED NO-LABEL
     NumCard AT ROW 13.93 COL 98.1 RIGHT-ALIGNED NO-LABEL
     NumChk AT ROW 13.97 COL 61 RIGHT-ALIGNED NO-LABEL
     DiscSum AT ROW 14.17 COL 38.5 RIGHT-ALIGNED NO-LABEL
     NettoSum AT ROW 15.3 COL 38.4 RIGHT-ALIGNED NO-LABEL
     SaldoSum AT ROW 16.47 COL 76.1 RIGHT-ALIGNED NO-LABEL
     TotalPay AT ROW 16.67 COL 38.5 RIGHT-ALIGNED NO-LABEL
     Mustpay AT ROW 17.77 COL 76.1 RIGHT-ALIGNED NO-LABEL
     CreditSum AT ROW 17.93 COL 38.4 RIGHT-ALIGNED NO-LABEL
     RestLimit AT ROW 18.93 COL 76.1 RIGHT-ALIGNED NO-LABEL
     LimitSum AT ROW 18.97 COL 38.4 RIGHT-ALIGNED NO-LABEL
     "Чеков" VIEW-AS TEXT
          SIZE 6 BY 1 AT ROW 13.7 COL 43.9
          BGCOLOR 8 FGCOLOR 1
     "Лимит кредита" VIEW-AS TEXT
          SIZE 15.5 BY .83 AT ROW 18.93 COL 2.8
          BGCOLOR 8 FGCOLOR 1
     "Cумма к оплате" VIEW-AS TEXT
          SIZE 15.5 BY 1 AT ROW 17.63 COL 40.4
          BGCOLOR 8 FGCOLOR 1
     "Сумма скидок" VIEW-AS TEXT
          SIZE 13.3 BY 1 AT ROW 14.07 COL 2.9
          BGCOLOR 8 FGCOLOR 1
     "Cумма в кредит" VIEW-AS TEXT
          SIZE 15.5 BY 1 AT ROW 17.63 COL 2.8
          BGCOLOR 8 FGCOLOR 1
     "Сумма оплат" VIEW-AS TEXT
          SIZE 13.3 BY 1 AT ROW 16.53 COL 2.9
          BGCOLOR 8 FGCOLOR 1
     "Остаток лимита" VIEW-AS TEXT
          SIZE 15.5 BY .83 AT ROW 18.93 COL 40.4
          BGCOLOR 8 FGCOLOR 1
     "Баланс карты" VIEW-AS TEXT
          SIZE 15.5 BY 1 AT ROW 16.33 COL 40.4
          BGCOLOR 8 FGCOLOR 1
     "Сумма покупок" VIEW-AS TEXT
          SIZE 13.3 BY 1 AT ROW 12.93 COL 2.8
          BGCOLOR 8 FGCOLOR 1
     "Сумма нетто" VIEW-AS TEXT
          SIZE 13.3 BY 1 AT ROW 15.27 COL 2.8
          BGCOLOR 8 FGCOLOR 1
     RECT-1 AT ROW 12.53 COL 1.4
     SPACE(0.33) SKIP(0.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE "Архивы по магазинам текущей фирмы"
         DEFAULT-BUTTON Btn_Cancel CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: hrtt-dis-card T "?" NO-UNDO ub dis-card
      TABLE: htt-dis-card T "?" NO-UNDO ub dis-card
      TABLE: rtt-dis-card T "?" NO-UNDO ub dis-card
      TABLE: r_dis-host B "?" ? ub dis-host
      TABLE: r_dis-obj B "?" ? ub dis-obj
      TABLE: r_shop B "?" ? ub shop
      TABLE: r_sysconf B "?" ? ub sysconf
      TABLE: tt-dis-card T "?" NO-UNDO ub dis-card
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-disc
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-dis-obj-r rs-host-obj d-disc */
/* BROWSE-TAB BR-dis-obj-b BR-dis-obj-r d-disc */
/* BROWSE-TAB BR-dis-host-r BR-dis-obj-b d-disc */
/* BROWSE-TAB BR-dis-host-b BR-dis-host-r d-disc */
ASSIGN
       FRAME d-disc:SCROLLABLE       = FALSE
       FRAME d-disc:HIDDEN           = TRUE.

/* SETTINGS FOR BROWSE BR-dis-host-b IN FRAME d-disc
   NO-ENABLE                                                            */
ASSIGN
       BR-dis-host-b:HIDDEN  IN FRAME d-disc                = TRUE
       BR-dis-host-b:NUM-LOCKED-COLUMNS IN FRAME d-disc     = 1.

ASSIGN
       BR-dis-host-r:NUM-LOCKED-COLUMNS IN FRAME d-disc     = 1.

ASSIGN
       BR-dis-obj-b:HIDDEN  IN FRAME d-disc                = TRUE
       BR-dis-obj-b:NUM-LOCKED-COLUMNS IN FRAME d-disc     = 1.

ASSIGN
       BR-dis-obj-r:NUM-LOCKED-COLUMNS IN FRAME d-disc     = 1.

/* SETTINGS FOR BUTTON Btn_Cost IN FRAME d-disc
   NO-ENABLE                                                            */
ASSIGN
       Btn_Cost:HIDDEN IN FRAME d-disc           = TRUE.

/* SETTINGS FOR FILL-IN CreditSum IN FRAME d-disc
   ALIGN-R 1                                                            */
/* SETTINGS FOR FILL-IN DiscSum IN FRAME d-disc
   ALIGN-R 1                                                            */
/* SETTINGS FOR FILL-IN f-smart-info-sums IN FRAME d-disc
   NO-ENABLE                                                            */
ASSIGN
       f-smart-info-sums:HIDDEN IN FRAME d-disc           = TRUE.

/* SETTINGS FOR FILL-IN LimitSum IN FRAME d-disc
   ALIGN-R 1                                                            */
/* SETTINGS FOR FILL-IN Mustpay IN FRAME d-disc
   ALIGN-R 1                                                            */
/* SETTINGS FOR FILL-IN NettoSum IN FRAME d-disc
   ALIGN-R 1                                                            */
/* SETTINGS FOR FILL-IN NumCard IN FRAME d-disc
   ALIGN-R 1                                                            */
/* SETTINGS FOR FILL-IN NumChk IN FRAME d-disc
   ALIGN-R 1                                                            */
/* SETTINGS FOR FILL-IN RestLimit IN FRAME d-disc
   ALIGN-R 1                                                            */
/* SETTINGS FOR FILL-IN SaldoSum IN FRAME d-disc
   ALIGN-R 1                                                            */
/* SETTINGS FOR RADIO-SET SelectCurr IN FRAME d-disc
   1                                                                    */
/* SETTINGS FOR FILL-IN TotalPay IN FRAME d-disc
   ALIGN-R 1                                                            */
/* SETTINGS FOR FILL-IN TotalSum IN FRAME d-disc
   ALIGN-R 1                                                            */
/* SETTINGS FOR FILL-IN val-title IN FRAME d-disc
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dis-host-b
/* Query rebuild information for BROWSE BR-dis-host-b
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH htt-dis-card NO-LOCK,
      FIRST dis-host WHERE TRUE /* Join to tt-dis-card incomplete */ NO-LOCK,
      EACH sysconf OF dis-host NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ", FIRST,,"
     _Query            is OPENED
*/  /* BROWSE BR-dis-host-b */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dis-host-r
/* Query rebuild information for BROWSE BR-dis-host-r
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH hrtt-dis-card NO-LOCK,
      FIRST r_dis-host WHERE TRUE /* Join to hrtt-dis-card incomplete */ NO-LOCK,
      EACH r_sysconf OF r_dis-host NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ", FIRST,,"
     _Query            is OPENED
*/  /* BROWSE BR-dis-host-r */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dis-obj-b
/* Query rebuild information for BROWSE BR-dis-obj-b
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-dis-card NO-LOCK,
      FIRST dis-obj WHERE TRUE /* Join to tt-dis-card incomplete */ NO-LOCK,
      EACH shop OF dis-obj NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ", FIRST,"
     _Query            is OPENED
*/  /* BROWSE BR-dis-obj-b */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dis-obj-r
/* Query rebuild information for BROWSE BR-dis-obj-r
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH rtt-dis-card NO-LOCK,
      FIRST r_dis-obj WHERE TRUE /* Join to rtt-dis-card incomplete */ NO-LOCK,
      EACH r_shop OF dis-obj NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ", FIRST,,"
     _Query            is OPENED
*/  /* BROWSE BR-dis-obj-r */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-disc
/* Query rebuild information for DIALOG-BOX d-disc
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-disc */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-disc d-disc
ON WINDOW-CLOSE OF FRAME d-disc /* Архивы по магазинам текущей фирмы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chk d-disc
ON CHOOSE OF B-chk IN FRAME d-disc /* Чеки */
DO:
    DEFINE VARIABLE varrid-list as character no-undo .

    if available ub.dis-obj THEN  do:
        run str/chk-docs.w (
                        input parparentproc
                       ,input '':U
                       ,input "d-card":U
                       ,input ?
                       ,input (if selectcurr = {&r-b-base} then dis-obj.obj-type else r_dis-obj.obj-type)
                       ,input  (if selectcurr = {&r-b-base} then dis-obj.obj-code else r_dis-obj.obj-code)
                       ,input '':U
                       ,input (if selectcurr = {&r-b-base} then entry(1, dis-obj.d-card, {&delim-par}) else entry(1, r_dis-obj.d-card, {&delim-par}) )
                       ,input 0
                       ,input  ?
                       ,input  ?
                       ,input 0
                       ,output varrid-list) no-error.
    end.
    if SelectCurr = {&r-b-rubl} then
    apply "entry" to br-dis-obj-r.
    else
    apply "entry" to br-dis-obj-b.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history d-disc
ON CHOOSE OF b-history IN FRAME d-disc /* История */
DO:
define variable parref-list as character no-undo .
CASE rs-host-obj:
  when {&g___object} then do:
    if
    (SelectCurr = {&r-b-rubl}
    and available r_dis-obj )
    or
    (SelectCurr = {&r-b-base}
    and
    available ub.dis-obj ) then
    run ref/cdchist.w (
                      INPUT parparentproc
                      ,input p-curr-host-code
                      ,input p-curr-obj-type
                      ,input p-curr-obj-code
                      ,input "":U
                      ,input "subject-object":U
                      ,input dis-obj.d-card
                      ,input ? /*dis-card.card-num*/
                      ,input (if selectcurr = {&r-b-base} then dis-obj.obj-type else r_dis-obj.obj-type)
                      ,input (if selectcurr = {&r-b-base} then dis-obj.obj-code else r_dis-obj.obj-code)
                      ,input (if selectcurr = {&r-b-base} then dis-obj.host-code else r_dis-obj.host-code)
                      ,input ? /*p-corr-user-db-num */
                      ,input "":U /*p-corr-user-name */
                      ,input {&table_dis-obj} /*p-subject*/
                      ,input ? /*p-db-num */
                      /*записи в выборке*/
                      ,input-output parref-list
                  ) no-error .
      if SelectCurr = {&r-b-rubl} then
      apply "entry" to BR-dis-obj-r.
      else
      apply "entry" to BR-dis-obj-b.
   end.
   when {&company} then do:
    if
    (SelectCurr = {&r-b-rubl}
    and available r_dis-host )
    or
    (SelectCurr = {&r-b-base}
    and
    available ub.dis-host ) then
     run ref/cdchist.w (
                        INPUT parparentproc
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input "":U
                        ,input "subject"
                        ,input dis-obj.d-card
                        ,input ? /*dis-card.card-num*/
                        ,input '':U
                        ,input 0
                        ,input (if selectcurr = {&r-b-base} then dis-host.host-code else r_dis-host.host-code)
                        ,input ? /*p-corr-user-db-num */
                        ,input "":U /*p-corr-user-name */
                        ,input {&table_dis-host} /*p-subject*/
                        ,input ? /*p-db-num */
                        /*записи в выборке*/
                        ,input-output parref-list
                    ) no-error .
      if SelectCurr = {&r-b-rubl} then
      apply "entry" to BR-dis-host-r.
      else
      apply "entry" to BR-dis-host-b.
     end.
   END CASE.
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print d-disc
ON CHOOSE OF B-print IN FRAME d-disc /* Печать */
DO:
define variable v-doc-rec as recid no-undo .
 CASE rs-host-obj:
     WHEN {&g___object} THEN DO:
      v-doc-rec = recid( ub.dis-obj ).
      DO WHILE available ub.dis-obj :
        GET prev br-dis-obj-b.
      END.
      run PrintProc IN THIS-PROCEDURE (rs-gen-private, rs-host-obj) .
      reposition br-dis-obj-b to recid v-doc-rec no-error.
      IF selectcurr = {&r-b-base} THEN
      apply "entry" to br-dis-obj-b in frame {&frame-name}.
      ELSE
      apply "entry" to br-dis-obj-r in frame {&frame-name}.
   END.
   WHEN {&company} THEN DO:
      v-doc-rec = recid( ub.dis-host ).
      DO WHILE available ub.dis-host :
          GET prev br-dis-host-b.
      END.
      run PrintProc IN THIS-PROCEDURE (rs-gen-private, rs-host-obj) .
      reposition br-dis-host-b to recid v-doc-rec no-error.
      IF selectcurr = {&r-b-base} THEN
      apply "entry" to br-dis-host-b in frame {&frame-name}.
      ELSE
      apply "entry" to br-dis-host-r in frame {&frame-name}.
  END.
 END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cost d-disc
ON CHOOSE OF Btn_Cost IN FRAME d-disc /* Учет */
DO:
  if available ub.dis-obj
  or available r_Dis-obj
  then do:
    define variable v-host-code as integer   no-undo .
    define variable v-obj-type as character no-undo .
    define variable v-obj-code as integer no-undo .
    define variable v-base-sum as decimal no-undo .
    define variable v-rubl-sum as decimal no-undo .
    case selectcurr:
      when {&r-b-rubl} then do:
        assign
        v-obj-type = (if available r_dis-obj
                      then r_dis-obj.obj-type
                      else ?)
        v-obj-code = (if available r_dis-obj
                      then r_dis-obj.obj-code
                      else ?)
        v-base-sum = r_dis-obj.gds-tot-b0
        v-rubl-sum = r_dis-obj.gds-tot-r0
        .
      end.
      when {&r-b-base} then do:
        assign
        v-obj-type = (if available dis-obj
                      then dis-obj.obj-type
                      else ?)
        v-obj-code = (if available dis-obj
                      then dis-obj.obj-code
                      else ?)
        v-base-sum = dis-obj.gds-tot-b0
        v-rubl-sum = dis-obj.gds-tot-r0
        .
      end.
    end.
    if v-obj-type = ? then do:
      return no-apply.
    end.
    { gbl/hostcode.i
      v-obj-type
      v-obj-code
      v-host-code
    }

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_archive_cost':U
      {&cntxt-object}
      v-host-code
      v-obj-type
      v-obj-code
      0
      0
      0
      true
      LogRes
    }
    if NOT LogRes then
        return no-apply.
    else do:
      message
      substitute("Сумма учетных цен (б.в.) : &1&2"  +
                  "Сумма учетных цен ({&abbr_rub}.) : &3"
                  ,v-base-sum
                  ,{&new-line}
                  ,v-rubl-sum)
                  view-as alert-box INFORMATION
      title substitute( "По объекту &1&2"
                        ,v-obj-type
                        ,v-obj-code ) .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rs-gen-private
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-gen-private d-disc
ON VALUE-CHANGED OF Rs-gen-private IN FRAME d-disc
DO:
  assign rs-gen-private.
  {&view-hide-list1}.
  RUN OpenBr IN THIS-PROCEDURE (
                                input t-legacy
                              , input t-subsid
                              , input selectcurr
                              , input rs-gen-private
                              , input rs-host-obj).
  IF rs-host-obj = {&g___object} THEN DO:
      IF SELECTcurr = {&r-b-base} THEN
      apply "ENTRY" to BR-dis-obj-b.
      ELSE
      apply "ENTRY" to BR-dis-obj-r.
  END.
  IF rs-host-obj = {&company} THEN DO:
      IF SELECTcurr = {&r-b-base} THEN
      apply "ENTRY" to BR-dis-host-b.
      ELSE
      apply "ENTRY" to BR-dis-host-r.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-host-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-host-obj d-disc
ON VALUE-CHANGED OF rs-host-obj IN FRAME d-disc
DO:
  assign RS-host-obj.
  RUN openbr IN THIS-PROCEDURE (
                                 input t-legacy
                               , input t-subsid
                               , INPUT selectcurr
                               , INPUT rs-gen-private
                               , input rs-host-obj).
  IF rs-host-obj = {&g___object} THEN DO:
    ENABLE
    b-chk
    btn_cost
    with frame {&frame-name} .
  if SelectCurr = {&r-b-rubl} then do:
    run diasize_restore-orig-size in this-procedure .
    run diasize_set-browse-handle in this-procedure
      (input browse BR-dis-obj-r :handle
      ) .
    run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  RECT-1 :handle
      ) .
    run diasize_restore-current-size in this-procedure .
    run GetSums in this-procedure .
    {&view-hide-list1}.
    apply "ENTRY" to BR-dis-obj-r.
  end.
  else do:
     run diasize_restore-orig-size in this-procedure .
    run diasize_set-browse-handle in this-procedure
      (input browse BR-dis-obj-b :handle
      ) .
    run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  RECT-1 :handle
      ) .
    run diasize_restore-current-size in this-procedure .

    run GetSums in this-procedure .
    {&view-hide-list1}.
    apply "ENTRY" to BR-dis-obj-b.
  end.
  END. /*rs-host-object = {&g___object}*/
  ELSE DO:
    DISABLE
    b-chk
    btn_cost
    with frame {&frame-name} .
    if SelectCurr = {&r-b-rubl} then do:
      run diasize_restore-orig-size in this-procedure .
      run diasize_set-browse-handle in this-procedure
        (input browse BR-dis-host-r :handle
        ) .
      run diasize_add_browse in this-procedure
        (input  'width':u
        ,input  RECT-1 :handle
        ) .
      run diasize_restore-current-size in this-procedure .
      run GetSums in this-procedure  .
      {&view-hide-list1}.
      apply "ENTRY" to BR-dis-host-r.
    end.
    else do:
      run diasize_restore-orig-size in this-procedure .
      run diasize_set-browse-handle in this-procedure
        (input browse BR-dis-host-b :handle
        ) .
      run diasize_add_browse in this-procedure
        (input  'width':u
        ,input  RECT-1 :handle
        ) .
      run diasize_restore-current-size in this-procedure .

      run GetSums in this-procedure .
      {&view-hide-list1}.
      apply "ENTRY" to BR-dis-host-b.
    end.
  END. /*if r-host-obj = {&company}*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectCurr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectCurr d-disc
ON VALUE-CHANGED OF SelectCurr IN FRAME d-disc
DO:
  assign SelectCurr.
  if rs-host-obj = {&g___object} then do:
    if SelectCurr = {&r-b-base} then do:
      HIDE
      BR-dis-obj-r
      IN FRAME {&frame-name}
      .
      enable
      BR-dis-obj-b
      with frame {&frame-name} .
      VIEW
      BR-dis-obj-b
      IN FRAME {&frame-name}
      .
      run diasize_restore-orig-size in this-procedure .
      run diasize_set-browse-handle in this-procedure
        (input browse BR-dis-obj-b :handle
        ) .
      run diasize_add_browse in this-procedure
        (input  'width':u
        ,input  RECT-1 :handle
        ) .
      run diasize_restore-current-size in this-procedure .
      run GetSums in this-procedure  .
      {&view-hide-list1}.
      apply "ENTRY" to BR-dis-obj-b.
    end.
    else do:
      HIDE
      BR-dis-obj-b
      IN FRAME {&frame-name}
      .
      enable
      BR-dis-obj-r
      with frame {&frame-name} .

      VIEW
      BR-dis-obj-r
      IN FRAME {&frame-name}
      .
      run diasize_restore-orig-size in this-procedure .
      run diasize_set-browse-handle in this-procedure
        (input browse BR-dis-obj-r :handle
        ) .
      run diasize_add_browse in this-procedure
        (input  'width':u
        ,input  RECT-1 :handle
        ) .
      run diasize_restore-current-size in this-procedure .

      run GetSums in this-procedure .
      {&view-hide-list1}.
      apply "ENTRY" to BR-dis-obj-r.
    end.
  end.
  else do:
      if SelectCurr = {&r-b-base} then do:
      HIDE
      BR-dis-host-r
      IN FRAME {&frame-name}
      .
      enable
      BR-dis-host-b
      with frame {&frame-name} .
      VIEW
      BR-dis-host-b
      IN FRAME {&frame-name}
      .
      run diasize_restore-orig-size in this-procedure .
      run diasize_set-browse-handle in this-procedure
        (input browse BR-dis-host-b :handle
        ) .
      run diasize_add_browse in this-procedure
        (input  'width':u
        ,input  RECT-1 :handle
        ) .
      run diasize_restore-current-size in this-procedure .
      run GetSums in this-procedure  .
      {&view-hide-list1}.
      apply "ENTRY" to BR-dis-host-b.
    end.
    else do:
      HIDE
      BR-dis-host-b
      IN FRAME {&frame-name}
      .
      enable
      BR-dis-host-r
      with frame {&frame-name} .

      VIEW
      BR-dis-host-r
      IN FRAME {&frame-name}
      .
      run diasize_restore-orig-size in this-procedure .
      run diasize_set-browse-handle in this-procedure
        (input browse BR-dis-host-r :handle
        ) .
      run diasize_add_browse in this-procedure
        (input  'width':u
        ,input  RECT-1 :handle
        ) .
      run diasize_restore-current-size in this-procedure .

      run GetSums in this-procedure .
      {&view-hide-list1}.
      apply "ENTRY" to BR-dis-host-r.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-legacy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-legacy d-disc
ON VALUE-CHANGED OF T-legacy IN FRAME d-disc /* Перевыпуск */
DO:
  assign
  t-legacy.
  if ub.dis-card.is-subsid = yes
  and t-legacy = yes
  then do:
    assign
    t-subsid = yes.
    display
    t-subsid
    with frame {&frame-name} .
    disable
    t-subsid
    with frame {&frame-name} .
  end.
  else do:
    enable
    t-subsid
    with frame {&frame-name} .
  end.
  run fill-tables in this-procedure ( input t-legacy, input t-subsid ).
  run openbr in this-procedure ( input t-legacy
                               , input t-subsid
                               , input selectcurr
                               , input rs-gen-private
                               , input rs-host-obj).
  RUN start-mv-clmnbr-dis-obj-b.
  RUN start-mv-clmnbr-dis-obj-r.
  run GetSums in this-procedure .
  {&view-hide-list1}.
  CASE t-legacy:
    when yes then do:
      display {&List-1} with frame {&frame-name}.
    end.
    when no then do:
      hide lnumcard numcard in frame {&frame-name}.
    end.
  END CASE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-subsid
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-subsid d-disc
ON VALUE-CHANGED OF T-subsid IN FRAME d-disc /* Дополнит-ные */
DO:
  assign
  t-subsid.
  run fill-tables in this-procedure ( input t-legacy, input t-subsid).
  run openbr in this-procedure (
                                 input t-legacy
                               , input t-subsid
                               , input selectcurr
                               , input rs-gen-private
                               , input rs-host-obj).
  RUN start-mv-clmnbr-dis-obj-b.
  RUN start-mv-clmnbr-dis-obj-r.
  run GetSums in this-procedure .
  {&view-hide-list1}.
  CASE t-subsid:
    when yes then do:
      display {&List-1} with frame {&frame-name}.
    end.
    when no then do:
      hide lnumcard numcard in frame {&frame-name}.
    end.
  END CASE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dis-host-b
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-disc


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i
  &disable_diasize_init=true }
{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/srt-clmn.i
  &browse-name    = "BR-dis-obj-b"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-BR-dis-obj-b}"
  &sort-clmn_1    = "ub.dis-obj.obj-code"
  &sort-clmn_2    = "ub.dis-obj.d-card"
  &sort-clmn_3    =  "vob"
  &open-query     = "run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}


{ gbl/srt-clmn.i
  &browse-name    = "BR-dis-obj-r"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-BR-dis-obj-r}"
  &sort-clmn_1    = "r_dis-obj.obj-code"
  &sort-clmn_2    = "r_dis-obj.d-card"
  &sort-clmn_3   = "vor"
  &open-query     = "run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/srt-clmn.i
  &browse-name    = "BR-dis-host-b"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-BR-dis-host-b}"
  &sort-clmn_1    = "ub.dis-host.host-code"
  &sort-clmn_2    = "ub.dis-host.d-card"
  &sort-clmn_3   = "vhb"
  &open-query     = "run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj)."
  &open-query-otherwise = "run OpenBr in this-procedure(input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/srt-clmn.i
  &browse-name    = "BR-dis-host-r"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-BR-dis-host-r}"
  &sort-clmn_1    = "r_dis-host.host-code"
  &sort-clmn_2    = "r_dis-host.d-card"
  &sort-clmn_3   = "vhr"
  &open-query     = "run OpenBr in this-procedure (input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj)."
  &open-query-otherwise = "run OpenBr in this-procedure(input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/mv-clmn.i
    &browse-name = "br-dis-obj-b"
    &frame-name = "{&frame-name}"
    &ext-col = 9
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9'"
    &prev-order-column-condition_1 = " t-legacy = no and t-subsid = no "
    &prev-order-column_2 = "'9,1,2,3,4,5,6,7,8'"
    &prev-order-column-condition_2 = " t-legacy = yes or t-subsid = yes "
   }

  { gbl/mv-clmn.i
    &browse-name = "br-dis-obj-r"
    &frame-name = "{&frame-name}"
    &ext-col = 9
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9'"
    &prev-order-column-condition_1 = " t-legacy = no and t-subsid = no "
    &prev-order-column_2 = "'9,1,2,3,4,5,6,7,8'"
    &prev-order-column-condition_2 = " t-legacy = yes or t-subsid = yes"
    }


  { gbl/mv-clmn.i
    &browse-name = "br-dis-host-b"
    &frame-name = "{&frame-name}"
    &ext-col = 9
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9'"
    &prev-order-column-condition_1 = " t-legacy = no and t-subsid = no "
    &prev-order-column_2 = "'9,1,2,3,4,5,6,7,8'"
    &prev-order-column-condition_2 = " t-legacy = yes or t-subsid = yes "
    }

  { gbl/mv-clmn.i
    &browse-name = "br-dis-host-r"
    &frame-name = "{&frame-name}"
    &ext-col = 9
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9'"
    &prev-order-column-condition_1 = " t-legacy = no and t-subsid = no "
    &prev-order-column_2 = "'9,1,2,3,4,5,6,7,8'"
    &prev-order-column-condition_2 = " t-legacy = yes or t-subsid = yes "
    }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

    define variable v-ok as logical   no-undo .
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_discount-cards-totals_print':U
      {&cntxt-firm}
      v-cntxt-host-code-obj
      '':U
      0
      0
      0
      0
      false
      LogRes
    }
    if NOT LogRes then
        do:
            message
                "У Вас недостаточно прав" skip
                "для выполнения данного действия." skip
                "Обратитесь к администратору системы." view-as alert-box error.
            LEAVE MAIN-BLOCK .
        end.
    find first ub.dis-card no-lock
      where ub.dis-card.d-card = inp-d-card
      no-error .
    if not available ub.dis-card then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена дисконтная карта с номером " inp-d-card
        view-as alert-box error.
      undo, return error .
    END.
    find first ub.clients no-lock
      where ub.clients.obj-type = ub.dis-card.cli-type
        and ub.clients.obj-code = ub.dis-card.cli-code
        no-error .
    if not available ub.clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден контрагент" ub.dis-card.cli-type ub.dis-card.cli-code skip
        view-as alert-box error.
      undo, return error .
    END.
    assign
      globalcard = (ub.dis-card.emitent-host-code = 0)
    .
    if not globalcard then do:
      { gbl/basecode.i ub.dis-card.emitent-host-code v-glob-curr-code }
    end.
    FIND FIRST ub.sysconf No-LOCK WHERE ub.sysconf.host-code = p-curr-host-code No-ERROR.
    IF Not avail ub.sysconf then do:
      message "Не найдена запись о фирме " p-curr-host-code
      view-as alert-box ERROR.
      return error.
    END.
    assign
    SelectCurr:radio-buttons =  "{&abbr_rubli_firstshift}" + {&comma-char} + {&r-b-rubl} + {&comma-char} +
                            "Баз.вал." + {&comma-char} + {&r-b-base}
    rs-gen-private = 0
    rs-host-obj = {&g___object}
    .
    { gbl/curr-r-b.i
      v-curr-r-b
    }
    SelectCurr = v-curr-r-b.
    assign
    glob-val = (if globalcard then one-base-cur-for-objs(output v-glob-curr-code) else yes)
    .
    RUN MYenable in this-procedure .
    run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  RECT-1 :handle
      ) .
    run diasize_init in this-procedure .
    APPLY "VALUE-CHANGED" to SelectCurr.
    display selectCUrr  with frame {&frame-name}.

   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
   END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-disc  _DEFAULT-DISABLE
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
  HIDE FRAME d-disc.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-disc  _DEFAULT-ENABLE
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
  DISPLAY T-legacy T-subsid SelectCurr Rs-gen-private rs-host-obj
          f-smart-info-sums val-title TotalSum lNumCard NumCard NumChk DiscSum
          NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum
      WITH FRAME d-disc.
  ENABLE Btn_Cancel B-chk B-print b-history B-help RECT-1 T-legacy T-subsid
         SelectCurr Rs-gen-private rs-host-obj BR-dis-obj-r BR-dis-obj-b
         BR-dis-host-r TotalSum lNumCard NumCard NumChk DiscSum NettoSum
         SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum
      WITH FRAME d-disc.
  VIEW FRAME d-disc.
  {&OPEN-BROWSERS-IN-QUERY-d-disc}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables d-disc
PROCEDURE fill-tables :
define input parameter  t-legacy as logical no-undo.
define input parameter t-subsid as logical no-undo .
define buffer buf_dis-card for ub.dis-card.
for each tt-dis-card :
    delete tt-dis-card.
end.
for each rtt-dis-card :
    delete rtt-dis-card.
end.
for each htt-dis-card :
    delete htt-dis-card.
end.
for each hrtt-dis-card :
    delete hrtt-dis-card.
end.

CASE t-legacy:
  when no then do:
    CASE t-subsid:
      when no then do:
        create tt-dis-card.
        buffer-copy ub.dis-card to tt-dis-card.

        create rtt-dis-card.
        buffer-copy ub.dis-card to rtt-dis-card.
        create htt-dis-card.
        buffer-copy ub.dis-card to htt-dis-card.

        create hrtt-dis-card.
        buffer-copy ub.dis-card to hrtt-dis-card.
        assign
        numcard = 1.
        find first current_dis-card no-lock where recid(current_dis-card) = recid(dis-card).
      end.  /*t-subsid = no*/
      when yes then do:
        assign
        numcard = 0.
        for each buf_dis-card no-lock where buf_dis-card.main-card = ub.dis-card.main-card:
          if buf_dis-card.main-card = buf_dis-card.d-card then do:
            find first current_dis-card no-lock where recid(current_dis-card) = recid(buf_dis-card).
          end.
          create tt-dis-card.
            buffer-copy buf_dis-card to tt-dis-card.
          create rtt-dis-card.
            buffer-copy buf_dis-card to rtt-dis-card.
            create htt-dis-card.
              buffer-copy buf_dis-card to htt-dis-card.
            create hrtt-dis-card.
              buffer-copy buf_dis-card to hrtt-dis-card.
          assign
          numcard = numcard + 1.
        end.
        find first current_dis-card no-lock where recid(current_dis-card) = recid(dis-card).
      end.  /*t-subsid = yes*/
    END CASE.
  end. /*t-legacy = no*/
  when yes then do:
    CASE t-subsid :
      when no then do:
        assign
        numcard = 0.
        for each buf_dis-card no-lock where buf_dis-card.card-num = ub.dis-card.card-num:
          if buf_dis-card.overissue-num = 0 then do:
            find first current_dis-card no-lock where recid(current_dis-card) = recid(ub.dis-card).
          end.
          create tt-dis-card.
            buffer-copy buf_dis-card to tt-dis-card.
          create rtt-dis-card.
            buffer-copy buf_dis-card to rtt-dis-card.
            create htt-dis-card.
              buffer-copy buf_dis-card to htt-dis-card.
            create hrtt-dis-card.
              buffer-copy buf_dis-card to hrtt-dis-card.
          assign
          numcard = numcard + 1.
        end.
      end. /*t-subsid = no*/
      when yes then do:
        assign
        numcard = 0.
        for each buf_dis-card no-lock where buf_dis-card.first-main-card = ub.dis-card.first-main-card:
          if buf_dis-card.first-main-card = buf_dis-card.d-card then do:
            find first current_dis-card no-lock where recid(current_dis-card) = recid(buf_dis-card).
          end.
          create tt-dis-card.
          buffer-copy buf_dis-card to tt-dis-card.
          create rtt-dis-card.
          buffer-copy buf_dis-card to rtt-dis-card.
          create htt-dis-card.
          buffer-copy buf_dis-card to htt-dis-card.
          create hrtt-dis-card.
          buffer-copy buf_dis-card to hrtt-dis-card.
          assign
          numcard = numcard + 1.
        end.
      end.  /*t-subsid = yes*/
    END CASE.
  end. /*t-legacy = yes*/
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GetSums d-disc
PROCEDURE GetSums :
define buffer buf_tt-dis-card for tt-dis-card.
define variable v-exch-rate like ub.curr-accnt.exch-rate no-undo .
define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .
define variable v-abbr-curr as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE v-ok-tot-sums AS logical NO-UNDO.
DEFINE VARIABLE v-ok AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-found AS logical NO-UNDO.
define buffer buf_dis-host for ub.dis-host.
assign frame {&frame-name}
t-legacy
t-subsid
.
run fill-tables in this-procedure ( input t-legacy, input t-subsid).
CASE t-legacy:
  when no then do:
    CASE t-subsid:
      when no then do:
        v-ok-tot-sums = YES.
        FOR EACH buf_dis-host no-lock where
                buf_dis-host.d-card = inp-d-card
          and buf_dis-host.host-code > 0
          and (globalcard or buf_dis-host.host-code = p-curr-host-code)
          and buf_dis-host.dt-code = 0
          :

          v-ok  = dc-smart_is-this-correct( INPUT buf_dis-host.dt-code /*v-dt-code*/
                                 ,INPUT {&TABLE_dis-host}
                                 ,INPUT v-cntxt-db-num
                                 ,INPUT ub.dis-card.TYPE
                                 ,INPUT ub.dis-card.emitent-host-code
                                 ,INPUT (IF buf_Dis-host.host-code > 0 THEN {&cmp} ELSE "")
                                 ,INPUT buf_dis-host.host-code
                                 ,INPUT dis-card.d-card).
          v-ok-tot-sums = v-ok-tot-sums AND (v-ok = "+").
          v-found = YES.

          ACCUMULATE
          buf_dis-host.pay-tot-rubl ( TOTAL )
          buf_dis-host.gds-tot-rubl ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-rubl ( TOTAL )
          buf_dis-host.pay-tot-base ( TOTAL )
          buf_dis-host.gds-tot-base ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-base ( TOTAL )
          .
        END.
      end.
      when yes then do:
        v-ok-tot-sums = YES.
        for each buf_tt-dis-card no-lock where
               buf_tt-dis-card.main-card = ub.dis-card.main-card,
            EACH buf_dis-host no-lock where
                 buf_dis-host.d-card = buf_tt-dis-card.d-card
          and buf_dis-host.host-code > 0
          and buf_dis-host.dt-code = 0
          and (globalcard or buf_dis-host.host-code = p-curr-host-code):
        v-ok  = dc-smart_is-this-correct( INPUT buf_dis-host.dt-code /*v-dt-code*/
                               ,INPUT {&TABLE_dis-host}
                               ,INPUT v-cntxt-db-num
                               ,INPUT buf_TT-dis-card.TYPE
                               ,INPUT BUF_TT-dis-card.emitent-host-code
                                 ,INPUT (IF buf_Dis-host.host-code > 0 THEN {&cmp} ELSE "")
                                 ,INPUT buf_dis-host.host-code
                                 ,INPUT buf_tt-dis-card.d-card).

        v-ok-tot-sums = v-ok-tot-sums AND (v-ok = "+").
        v-found = YES.

          ACCUMULATE
          buf_dis-host.pay-tot-rubl ( TOTAL )
          buf_dis-host.gds-tot-rubl ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-rubl ( TOTAL )
          buf_dis-host.pay-tot-base ( TOTAL )
          buf_dis-host.gds-tot-base ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-base ( TOTAL )
          .
        END.
      end.
    END CASE.
  end.
  when yes then do:
    CASE t-subsid:
      when no then do:
        v-ok-tot-sums = YES.
        for each buf_tt-dis-card no-lock,
            each buf_dis-host no-lock where
                  buf_dis-host.d-card = buf_tt-dis-card.d-card
              and buf_dis-host.host-code > 0
              AND (globalcard or buf_dis-host.host-code = p-curr-host-code)
              and buf_dis-host.dt-code = 0
              :
            v-ok  = dc-smart_is-this-correct( INPUT buf_dis-host.dt-code /*v-dt-code*/
                                   ,INPUT {&TABLE_dis-host}
                                   ,INPUT v-cntxt-db-num
                                   ,INPUT buf_TT-dis-card.TYPE
                                   ,INPUT BUF_TT-dis-card.emitent-host-code
                                     ,INPUT (IF buf_Dis-host.host-code > 0 THEN {&cmp} ELSE "")
                                     ,INPUT buf_dis-host.host-code
                                     ,INPUT buf_tt-dis-card.d-card).

            v-ok-tot-sums = v-ok-tot-sums AND (v-ok = "+").
            v-found = YES.

          ACCUMULATE
          buf_dis-host.pay-tot-rubl ( TOTAL )
          buf_dis-host.gds-tot-rubl ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-rubl ( TOTAL )
          buf_dis-host.pay-tot-base ( TOTAL )
          buf_dis-host.gds-tot-base ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-base ( TOTAL )
          .
        end.
      end.
      when yes then do:
        v-ok-tot-sums = YES.
        for each buf_tt-dis-card no-lock
            where  buf_tt-dis-card.first-main-card = ub.dis-card.first-main-card ,
            each buf_dis-host no-lock where
                buf_dis-host.d-card = buf_tt-dis-card.d-card
              and buf_dis-host.host-code > 0
              AND (globalcard or buf_dis-host.host-code = p-curr-host-code)
              and buf_dis-host.dt-code = 0
              :
            v-ok  = dc-smart_is-this-correct( INPUT buf_dis-host.dt-code /*v-dt-code*/
                                   ,INPUT {&TABLE_dis-host}
                                   ,INPUT v-cntxt-db-num
                                   ,INPUT buf_TT-dis-card.TYPE
                                   ,INPUT BUF_TT-dis-card.emitent-host-code
                                     ,INPUT (IF buf_Dis-host.host-code > 0 THEN {&cmp} ELSE "")
                                     ,INPUT buf_dis-host.host-code
                                     ,INPUT buf_tt-dis-card.d-card).

            v-ok-tot-sums = v-ok-tot-sums AND (v-ok = "+").
            v-found = YES.

          ACCUMULATE
          buf_dis-host.pay-tot-rubl ( TOTAL )
          buf_dis-host.gds-tot-rubl ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-rubl ( TOTAL )
          buf_dis-host.pay-tot-base ( TOTAL )
          buf_dis-host.gds-tot-base ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-base ( TOTAL )
          .
        end.
      end.
    END CASE.
  end.
END CASE.
if glob-val then do:
  run cur-time in this-procedure(output v-today, output v-time).
  { gbl/exchrate.i v-glob-curr-code v-today v-exch-rate v-exch-scale  v-abbr-curr no-error }
  if error-status:error then
  v-exch-rate = ?.
end.
else do:
  assign
  v-exch-rate = ?.
end.

if SelectCurr = {&r-b-rubl} then do:
  ASSIGN
  TotalPay = ( ACCUM TOTAL buf_dis-host.pay-tot-rubl)
  TotalSum = ( ACCUM TOTAL buf_dis-host.gds-tot-rubl )
  DiscSum = ( ACCUM TOTAL buf_dis-host.gds-dis-rubl )
  SaldoSUm = dis-card.saldo-rubl
  TotalPayPrim = ( ACCUM TOTAL buf_dis-host.pay-tot-base)
  TotalSumPrim = ( ACCUM TOTAL buf_dis-host.gds-tot-base )
  DiscSumPrim = ( ACCUM TOTAL buf_dis-host.gds-dis-base )
  SaldoSumPrim = dis-card.saldo-base
  .
  ASSIGN NettoSum = TotalSum - DiscSum
  CreditSUm = NettoSum - TotalPay
  MustPay = if saldosum < 0 then (- saldosum) else 0
  NettoSumPrim = TotalSumPrim - DiscSumPrim
  CreditSUmPrim = NettoSumPrim - TotalPayPrim
  MustPayPrim = if saldosumPrim < 0 then (- saldosum) else 0
  NumChk =  ACCUM TOTAL buf_dis-host.num-chk
  .
  /*лимит кредита лежит в R-b*/
  /*Prim - суммы в base*/
  IF v-curr-r-b = {&r-b-rubl} THEN DO:
    assign
    LimitSum = current_dis-card.lim-kr
    RestLimit = LimitSum - (if mustpay > 0 then mustpay else 0)
    LimitSumPrim = current_dis-card.lim-kr / v-exch-rate * v-exch-scale
    RestLimitPrim = LimitSumPrim - (if mustpayPrim > 0 then mustpayPrim else 0)
        .
  END.
  else do:
    assign
    LimitSum =  current_dis-card.lim-kr * v-exch-rate / v-exch-scale
    RestLimit = LimitSum - (if mustpay > 0 then mustpay else 0)
    LimitSumPrim =  current_dis-card.lim-kr
    RestLimitPrim = LimitSumPrim - (if mustpayPrim > 0 then mustpayPrim else 0)
    .
  end.
end.
else do:
  ASSIGN
  TotalPay = ( ACCUM TOTAL buf_dis-host.pay-tot-base)
  TotalSum = ( ACCUM TOTAL buf_dis-host.gds-tot-base )
  DiscSum = ( ACCUM TOTAL buf_dis-host.gds-dis-base )
  SaldoSUm = dis-card.saldo-base
  TotalPayPrim = ( ACCUM TOTAL buf_dis-host.pay-tot-rubl)
  TotalSumPrim = ( ACCUM TOTAL buf_dis-host.gds-tot-rubl )
  DiscSumPrim = ( ACCUM TOTAL buf_dis-host.gds-dis-rubl )
  SaldoSumPrim = dis-card.saldo-rubl
  .

  ASSIGN
  NettoSum = TotalSum - DiscSum
  CreditSUm = NettoSum - TotalPay
  MustPay = if SaldoSUm < 0 then (- saldosum) else 0
  NettoSumPrim = TotalSumPrim - DiscSumPrim
  CreditSumPrim = NettoSumPrim - TotalPayPrim
  MustPayPrim = if SaldoSUmPrim < 0 then (- saldosumPrim) else 0
  NumChk =  ACCUM TOTAL buf_dis-host.num-chk .

  /*лимит кредита лежит в R-b*/
  /*Prim - суммы в rubl*/
  IF v-curr-r-b = {&r-b-rubl} THEN DO:
    assign
    LimitSum =  current_dis-card.lim-kr / v-exch-rate * v-exch-scale
    RestLimit = LimitSum - (if mustpay > 0 then mustpay else 0)
    LimitSumPrim =  current_dis-card.lim-kr
    RestLimitPrim = LimitSumPrim - (if mustpayPrim > 0 then mustpayPrim else 0)
    .
  END.
  else do:
    assign
    LimitSum =  current_dis-card.lim-kr
    RestLimit = LimitSum - (if mustpay > 0 then mustpay else 0)
    LimitSumPrim =  current_dis-card.lim-kr * v-exch-rate / v-exch-scale
    RestLimitPrim = LimitSumPrim  - (if mustpayPrim > 0 then mustpayPrim else 0)
    .
  end.
end.
IF NOT (V-OK-TOT-SUMS AND v-found) THEN
DISPLAY
F-SMART-INFO-SUMS
WITH FRAME {&FRAME-NAME}.
ELSE
HIDE
F-SMART-INFO-SUMS
in FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable d-disc
PROCEDURE Myenable :

 assign
 SelectCurr:radio-buttons in frame {&frame-name} = "{&abbr_rubli_firstshift}" + {&comma-char} + {&r-b-rubl} + {&comma-char} +
                                                   "Баз.вал." + {&comma-char} + {&r-b-base}
 rs-host-obj:radio-buttons in frame {&frame-name} = "Объекты" + {&comma-char} + {&g___object} + {&comma-char} +
                                                   "Фирмы" + {&comma-char} + {&company}

 br-dis-obj-r:title in frame {&frame-name} = "В {&abbr_rublyah}"
 br-dis-host-r:title in frame {&frame-name} = "В {&abbr_rublyah}"
 /*
 v-ok-dis-obj:visible IN BROWSE br-dis-obj-b = (v-cntxt-db-num > 0)
 v-ok-rdis-obj:visible IN BROWSE br-dis-obj-r = (v-cntxt-db-num > 0)
 v-ok-dis-host:visible IN BROWSE br-dis-host-b = (v-cntxt-db-num > 0)
 v-ok-rdis-host:visible IN BROWSE br-dis-host-r = (v-cntxt-db-num > 0)
 */
 .

  DISPLAY
  SelectCurr
  rs-gen-private
  rs-host-obj
  DiscSum
  Mustpay
  NettoSum
  NumChk
  TotalSum
  val-title
  CreditSum
  SaldoSum
  RestLimit
  LimitSum
  WITH FRAME {&frame-name}.
  assign
  ub.dis-obj.num-chk:read-only in browse br-dis-obj-b = yes
  r_dis-obj.num-chk:read-only in browse br-dis-obj-r = yes
  ub.dis-host.num-chk:read-only in browse br-dis-host-b = yes
  r_dis-host.num-chk:read-only in browse br-dis-host-r = yes
 .

  assign
  t-legacy = no
  t-subsid = no
  .
  ENABLE
  B-help
  b-history
  Btn_Cancel
  B-chk
  btn_cost
  B-print
  SelectCurr
  rs-gen-private
  rs-host-obj
  RECT-1 BR-dis-obj-r BR-dis-obj-b DiscSum Mustpay NettoSum NumChk RestLimit LimitSum
  TotalSum
  t-legacy
  t-subsid
  WITH FRAME {&frame-name}.
  VIEW FRAME {&frame-name}.
    /*если вызывающая программа discards.w находится в моде просмотра ПУЛА то открываемся с данными по одной конкретной карте*/
  assign
  t-legacy = (if p-legacy <> no then yes  else t-legacy)
  t-subsid = (if p-subsid <> no then yes  else t-subsid)
  .
  display
  t-legacy
  t-subsid
  with frame {&frame-name} .
  run fill-tables in this-procedure ( input t-legacy, input t-subsid).
  APPLY "VALUE-CHANGED" to T-legacy.

  IF rs-host-obj = {&g___object} THEN DO:
    hide
    br-dis-host-b
    br-dis-host-r
    in frame {&frame-name} .

  END.
  IF rs-host-obj = {&company} THEN DO:
    hide
    br-dis-obj-b
    br-dis-obj-r
    in frame {&frame-name} .

  END.
 END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr d-disc
PROCEDURE OpenBr :
define input parameter p-legacy as logical no-undo.
define input parameter p-is-subsid as logical no-undo .
DEFINE INPUT PARAMETER p-selectcurr AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-gen-private AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-host-obj AS character NO-UNDO.

DISABLE
br-dis-obj-b
br-dis-obj-r
br-dis-host-b
br-dis-host-r
WITH FRAME {&frame-name}.
hide
br-dis-obj-b
br-dis-obj-r
br-dis-host-b
br-dis-host-r
in FRAME {&frame-name}.

IF p-gen-private = 0
AND p-host-obj = {&g___object} THEN DO:

  ASSIGN
  vob:VISIBLE IN BROWSE br-dis-obj-b = NO
  vor:VISIBLE IN BROWSE br-dis-obj-r = NO
  .

  if globalcard then do:
    assign
    FRAME {&FRAME-NAME}:title = "Архивы по магазинам"
    .
  end.
  else do:
    assign
    FRAME {&FRAME-NAME}:title = "Архивы по магазинам текущей фирмы".
  end.
  assign
  FRAME {&FRAME-NAME}:title = FRAME {&FRAME-NAME}:title + substitute(" по карте &1 &2 &3 &4"
                                                                      , inp-d-card
                                                                      , (if t-legacy then "с учетом перевыпуска карт" else "":U)
                                                                      , (if t-subsid then "с учетом дополнительных карт" else "":U)
                                                                      , (if ub.dis-card.is-subsid then "(дополнительная карта)" else "")
                                                                      ).
  OPEN QUERY BR-dis-obj-r
  FOR EACH rtt-dis-card,
      EACH r_dis-obj WHERE
            r_dis-obj.d-card = rtt-dis-card.d-card
       AND r_dis-obj.dt-code = 0
      AND (if globalcard then true else r_dis-obj.host-code = p-curr-host-code) NO-LOCK,
        FIRST r_shop WHERE r_shop.obj-code = r_dis-obj.obj-code NO-LOCK

      BY r_dis-obj.d-card
          BY r_dis-obj.obj-type
          BY r_dis-obj.obj-code.

  OPEN QUERY BR-dis-obj-b
  FOR EACH tt-dis-card,
      each  ub.dis-obj  WHERE
            ub.dis-obj.d-card = tt-dis-card.d-card
      AND ub.dis-obj.dt-code = 0
       and
  (if globalcard then true else ub.dis-obj.host-code = p-curr-host-code) NO-LOCK,
       FIRST ub.shop WHERE ub.shop.obj-code = ub.dis-obj.obj-code NO-LOCK

      BY dis-obj.d-card
          BY dis-obj.obj-type
          BY dis-obj.obj-code.
   CASE p-selectcurr:
     WHEN {&r-b-rubl} THEN DO:
       DISPLAY
       br-dis-obj-r
       WITH FRAME {&FRAME-NAME}.
       ENABLE
       br-dis-obj-r
       WITH FRAME {&FRAME-NAME}.
       APPLY "entry" TO br-dis-obj-r.
     END.
       WHEN {&r-b-base} THEN DO:
         DISPLAY
         br-dis-obj-b
         WITH FRAME {&FRAME-NAME}.
         ENABLE
         br-dis-obj-b
         WITH FRAME {&FRAME-NAME}.
         APPLY "entry" TO br-dis-obj-b.
       END.

   END CASE.
END. /*
IF p-gen-private = 0
AND p-host-obj = {&g___object} THEN DO:

*/
IF p-gen-private = 1
AND p-host-obj = {&g___object} THEN DO:
  ASSIGN
  vob:VISIBLE IN BROWSE br-dis-obj-b = YES
  vor:VISIBLE IN BROWSE br-dis-obj-r = YES
  .

  if globalcard then do:
    assign
    FRAME {&FRAME-NAME}:title = "Архивы частных итогов по магазинам"
    .
  end.
  else do:
    assign
    FRAME {&FRAME-NAME}:title = "Архивы частных итогов по магазинам текущей фирмы".
  end.
  assign
  FRAME {&FRAME-NAME}:title = FRAME {&FRAME-NAME}:title + substitute(" по карте &1 &2 &3 &4"
                                                                      , inp-d-card
                                                                      , (if t-legacy then " с учетом перевыпуска карт" else "":U)
                                                                      , (if t-subsid then " с учетом дополнительных карт" else "":U )
                                                                      , (if ub.dis-card.is-subsid then "(дополнительная карта)" else "")
                                                                      ).
  OPEN QUERY BR-dis-obj-r
  FOR EACH rtt-dis-card,
      EACH r_dis-obj WHERE
            r_dis-obj.d-card = rtt-dis-card.d-card
       and  r_dis-obj.dt-code > 0
       AND (if globalcard then true else r_dis-obj.host-code = p-curr-host-code) NO-LOCK,
        FIRST r_shop WHERE r_shop.obj-code = r_dis-obj.obj-code NO-LOCK

      BY r_dis-obj.d-card
          BY r_dis-obj.obj-type
          BY r_dis-obj.obj-code.

  OPEN QUERY BR-dis-obj-b
  FOR EACH tt-dis-card,
      each  dis-obj  WHERE
            dis-obj.d-card = tt-dis-card.d-card
        and dis-obj.dt-code > 0
        and (if globalcard then true else dis-obj.host-code = p-curr-host-code) NO-LOCK,
        FIRST shop WHERE shop.obj-code = dis-obj.obj-code NO-LOCK

      BY dis-obj.d-card
          BY dis-obj.obj-type
          BY dis-obj.obj-code.
    CASE p-selectcurr:
      WHEN {&r-b-rubl} THEN DO:
        DISPLAY
        br-dis-obj-r
        WITH FRAME {&FRAME-NAME}.
        ENABLE
        br-dis-obj-r
        WITH FRAME {&FRAME-NAME}.
        APPLY "entry" TO br-dis-obj-r.
      END.
        WHEN {&r-b-base} THEN DO:
          DISPLAY
          br-dis-obj-b
          WITH FRAME {&FRAME-NAME}.
          ENABLE
          br-dis-obj-b
          WITH FRAME {&FRAME-NAME}.
          APPLY "entry" TO br-dis-obj-b.
        END.

    END CASE.
END. /*
IF p-gen-private = 1
AND p-host-obj = {&g___object} THEN DO:

*/
IF p-gen-private = 0
AND p-host-obj = {&company} THEN DO:
    ASSIGN
    vhb:VISIBLE IN BROWSE br-dis-host-b = NO
    vhr:VISIBLE IN BROWSE br-dis-host-r = NO
    .
  if globalcard then do:
    assign
    FRAME {&FRAME-NAME}:title = "Архивы по фирмам"
    .
  end.
  else do:
    assign
    FRAME {&FRAME-NAME}:title = "Архивы по фирме".
  end.

  assign
  FRAME {&FRAME-NAME}:title = FRAME {&FRAME-NAME}:title + substitute(" по карте &1 &2 &3 &4"
                                                                      , inp-d-card
                                                                      , (if t-legacy then " с учетом перевыпуска карт" else "":U)
                                                                      , (if t-subsid then " с учетом дополнительных карт" else "":U)
                                                                      , (if ub.dis-card.is-subsid then "(дополнительная карта)" else "")
                                                                      ).

  OPEN QUERY BR-dis-host-r
  FOR EACH hrtt-dis-card,
      EACH r_dis-host WHERE
            r_dis-host.d-card = hrtt-dis-card.d-card
       AND r_dis-host.dt-code = 0
       and (if globalcard then true else r_dis-host.host-code = p-curr-host-code) NO-LOCK,
        FIRST r_sysconf WHERE r_sysconf.host-code = r_dis-host.host-code NO-LOCK

      BY r_dis-host.d-card
          BY r_dis-host.host-code.

  OPEN QUERY BR-dis-host-b
  FOR EACH htt-dis-card,
      each  ub.dis-host  WHERE
            ub.dis-host.d-card = htt-dis-card.d-card
      and  ub.dis-host.dt-code = 0
      and  (if globalcard then true else ub.dis-host.host-code = p-curr-host-code) NO-LOCK,
        FIRST ub.sysconf WHERE ub.sysconf.host-code = ub.dis-host.host-code NO-LOCK

      BY ub.dis-host.d-card
          BY ub.dis-host.host-code
          .
    CASE p-selectcurr:
      WHEN {&r-b-rubl} THEN DO:
        DISPLAY
        br-dis-host-r
        WITH FRAME {&FRAME-NAME}.
        ENABLE
        br-dis-host-r
        WITH FRAME {&FRAME-NAME}.
        APPLY "entry" TO br-dis-host-r.
      END.
        WHEN {&r-b-base} THEN DO:
          DISPLAY
          br-dis-host-b
          WITH FRAME {&FRAME-NAME}.
          ENABLE
          br-dis-host-b
          WITH FRAME {&FRAME-NAME}.
          APPLY "entry" TO br-dis-host-b.
        END.

    END CASE.

  END. /*
IF p-gen-private = 0
AND p-host-obj = {&company} THEN DO:*/
IF p-gen-private = 1
AND p-host-obj = {&company} THEN DO:
  ASSIGN
  vhb:VISIBLE IN BROWSE br-dis-host-b = YES
  vhr:VISIBLE IN BROWSE br-dis-host-r = YES
  .
  if globalcard then do:
    assign
    FRAME {&FRAME-NAME}:title = "Архивы частных итогов по фирмам"
    .
  end.
  else do:
    assign
    FRAME {&FRAME-NAME}:title = "Архивы частных итогов по фирме".
  end.

  assign
  FRAME {&FRAME-NAME}:title = FRAME {&FRAME-NAME}:title + substitute(" по карте &1 &2 &3 &4"
                                                                      , inp-d-card
                                                                      , (if t-legacy then " с учетом перевыпуска карт" else "":U)
                                                                      , (if t-subsid then " с учетом дополнительных карт" else "":U)
                                                                      , (if ub.dis-card.is-subsid then "(дополнительная карта)" else "")
                                                                      ).
  OPEN QUERY BR-dis-host-r
  FOR EACH hrtt-dis-card,
      EACH r_dis-host WHERE
            r_dis-host.d-card = hrtt-dis-card.d-card
        and r_dis-host.dt-code > 0
        AND (if globalcard then true else r_dis-host.host-code = p-curr-host-code) NO-LOCK,
        FIRST r_sysconf WHERE r_sysconf.host-code = r_dis-host.host-code NO-LOCK

      BY r_dis-host.d-card
          BY r_dis-host.host-code.

  OPEN QUERY BR-dis-host-b
  FOR EACH htt-dis-card,
      each  dis-host  WHERE
            dis-host.d-card = htt-dis-card.d-card
        and dis-host.dt-code > 0
        and (if globalcard then true else dis-host.host-code = p-curr-host-code) NO-LOCK,
        FIRST sysconf WHERE sysconf.host-code = dis-host.host-code NO-LOCK

      BY dis-host.d-card
          BY dis-host.host-code.
  CASE p-selectcurr:
    WHEN {&r-b-rubl} THEN DO:
      DISPLAY
      br-dis-host-r
      WITH FRAME {&FRAME-NAME}.
      ENABLE
      br-dis-host-r
      WITH FRAME {&FRAME-NAME}.
      APPLY "entry" TO br-dis-host-r.
    END.
      WHEN {&r-b-base} THEN DO:
        DISPLAY
        br-dis-host-b
        WITH FRAME {&FRAME-NAME}.
        ENABLE
        br-dis-host-b
        WITH FRAME {&FRAME-NAME}.
        APPLY "entry" TO br-dis-host-b.
      END.

  END CASE.

          .
  END. /*
  IF p-gen-private = 1
  AND p-host-obj = {&company} THEN DO:*/
CASE (t-legacy or t-subsid):
    when no then do:
        hide
        NumCard in frame {&frame-name}
        lnumcard in frame {&frame-name}.
    end.
    when yes then do:
        display
        NumCard
        lnumcard
        with frame {&frame-name}.
    end.

END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc d-disc
PROCEDURE PrintProc :
DEFINE INPUT PARAMETER p-gen-private AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-host-obj AS CHARACTER NO-UNDO.
define variable sym1   as char format "X(1)" init ":".
define variable sym10 as char format "X(1)" init ":".
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-obj-code as integer FORMAT ">>>>9" no-undo.
define variable for-netto like ub.dis-obj.pay-tot-rubl no-undo.
define variable credit-sum like ub.dis-obj.pay-tot-rubl no-undo.
DEFINE VARIABLE v-sum-id AS CHARACTER NO-UNDO.

DEFINE FRAME List
sym1 column-label " " format "X(1)" space(0)
for-obj-code COLUMN-LABEL "Объект!Фирма"
v-sum-id COLUMN-LABEL "Частный итог" FORMAT "X(32)"
ub.dis-obj.gds-tot-rubl COLUMN-LABEL "Сумма товарная"
ub.dis-obj.gds-dis-rubl COLUMN-LABEL "Скидка товарная"
for-netto COLUMN-LABEL "Сумма нетто"
ub.dis-obj.pay-tot-rubl COLUMN-LABEL "Платежи"
credit-sum COLUMn-LABEL "Сумма в кредит"
ub.dis-obj.num-chk
ub.dis-obj.d-card COLUMN-LABEL "№ карты"
sym10 column-label " " format "X(1)"
HEADER  date_string AT 5 format "X(35)"
string( if SelectCurr = {&r-b-base} then "(баз.вал)" else "({&abbr_rubli})" ) format "X(20)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(193)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 193).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(193)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME list  .
run waitfram-show in this-procedure ("Ждите...").
CASE p-host-obj:
  WHEN {&g___object} THEN DO:
    GET next br-dis-obj-b.
    DO WHILE available dis-obj :
        DISPLAY STREAM PrnLibStream
        sym1
        dis-obj.obj-code @ for-obj-code
        dct-algo-get-sum-id-from-dt-code(INPUT dis-obj.dt-code) @ v-sum-id
        (if SelectCurr = {&r-b-base}
        then dis-obj.gds-tot-base
        else dis-obj.gds-tot-rubl) @ dis-obj.gds-tot-rubl
        (if SelectCurr = {&r-b-base}
        then dis-obj.gds-dis-base
        else dis-obj.gds-dis-rubl) @ dis-obj.gds-dis-rubl
        (if SelectCurr = {&r-b-base} then
        (dis-obj.gds-tot-base + dis-obj.sum-tot-base -
        dis-obj.gds-dis-base - dis-obj.sum-dis-base)
        else
        (dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl -
        dis-obj.gds-dis-rubl - dis-obj.sum-dis-rubl)) @ for-netto
        (if SelectCurr = {&r-b-base}
        then
        (dis-obj.gds-tot-base + dis-obj.sum-tot-base -
         dis-obj.gds-dis-base - dis-obj.sum-dis-base -
         dis-obj.pay-tot-base)
        else
        (dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl -
         dis-obj.gds-dis-rubl - dis-obj.sum-dis-rubl -
         dis-obj.pay-tot-rubl)) @ credit-sum
        dis-obj.num-chk
        (if SelectCurr = {&r-b-base}
        then dis-obj.pay-tot-base
        else dis-obj.pay-tot-rubl) @ dis-obj.pay-tot-rubl
        sym10
        dis-obj.d-card
        with FRAME list .
        DOWN STREAM PrnLibStream 1 with FRAME list  .
        GET next br-dis-obj-b.
    END.
  END.
  WHEN {&company} THEN DO:
    GET next br-dis-host-b.
    DO WHILE available dis-obj :
        DISPLAY STREAM PrnLibStream
        sym1
        ub.dis-host.host-code @ for-obj-code
        dct-algo-get-sum-id-from-dt-code(INPUT ub.dis-host.dt-code) @ v-sum-id
        (if SelectCurr = {&r-b-base}
        then ub.dis-host.gds-tot-base
        else ub.dis-host.gds-tot-rubl) @ dis-obj.gds-tot-rubl
        (if SelectCurr = {&r-b-base}
        then ub.dis-host.gds-dis-base
        else ub.dis-host.gds-dis-rubl) @ dis-obj.gds-dis-rubl
        (if SelectCurr = {&r-b-base} then
        (ub.dis-host.gds-tot-base - ub.dis-host.gds-dis-base)
        else
        (ub.dis-host.gds-tot-rubl  - ub.dis-host.gds-dis-rubl )) @ for-netto
        (if SelectCurr = {&r-b-base}
        then
        (ub.dis-host.gds-tot-base - ub.dis-host.gds-dis-base - ub.dis-host.pay-tot-base)
        else
        (ub.dis-host.gds-tot-rubl - ub.dis-host.gds-dis-rubl - ub.dis-host.pay-tot-rubl))
        @ credit-sum
        ub.dis-host.num-chk @ ub.dis-obj.num-chk
        (if SelectCurr = {&r-b-base}
        then ub.dis-host.pay-tot-base
        else ub.dis-host.pay-tot-rubl) @ ub.dis-obj.pay-tot-rubl
        sym10
        ub.dis-host.d-card @ ub.dis-obj.d-card
        with FRAME list .
        DOWN STREAM PrnLibStream 1 with FRAME list  .
        GET next br-dis-host-b.
     END.
  END.
END CASE.
UNDERLINE  STREAM PrnLibStream
sym1
for-obj-code
dis-obj.gds-tot-rubl
dis-obj.gds-dis-rubl
for-netto
dis-obj.pay-tot-rubl
credit-sum
dis-obj.num-chk
sym10
with FRAME list .


DISPLAY STREAM PrnLibStream
sym1
"ИТОГО б.в."  @ for-obj-code
(IF SelectCurr = {&r-b-rubl} or SelectCurr = "" then TotalSumPrim
                                           else TotalSum)
                                            @ dis-obj.gds-tot-rubl
(IF SelectCurr = {&r-b-rubl} or SelectCurr = "" then DiscSumprim
                                           else DiscSum)
                                            @ dis-obj.gds-dis-rubl
(IF SelectCurr = {&r-b-rubl} or SelectCurr = "" then NettoSumPrim else NettoSum) @ for-netto
(IF SelectCurr = {&r-b-rubl} or SelectCurr = "" then TotalPayPrim else TotalPay) @ dis-obj.pay-tot-rubl
(IF SelectCurr = {&r-b-rubl} or SelectCurr = "" then (NettoSumPrim - TotalPayPrim)
                                   else (NettoSum - TotalPay)) @ credit-sum
NumChk @ dis-obj.num-chk
sym10
with frame list.

DOWN STREAM PrnLibStream 1 with FRAME list  .

DISPLAY STREAM PrnLibStream
sym1
"ИТОГО {&abbr_rub}"  @ for-obj-code
(IF SelectCurr = {&r-b-rubl} or SelectCurr = "" then TotalSum
                                           else TotalSumPrim)
                                                        @ dis-obj.gds-tot-rubl
(IF SelectCurr = "rubl" or SelectCurr = "" then DiscSum
                                           else DiscSumPrim)
                                                        @ dis-obj.gds-dis-rubl
(IF SelectCurr = "rubl" or SelectCurr = "" then NettoSum else NettoSumPrim) @ for-netto
(IF SelectCurr = "rubl" or SelectCurr = "" then TotalPay else TotalPayPrim) @ dis-obj.pay-tot-rubl
(IF SelectCurr = "rubl" or SelectCurr = "" then (NettoSum - TotalPay)
                           else (NettoSumPrim - TotalPayPrim)) @ credit-sum
NumChk @ dis-obj.num-chk
sym10
with frame list.

HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.
/*
assign
g#rep-tblname = ""
g#rep-tblrid = -117
g#rep-updflds = string( "Архивы по карте |" ) .
*/
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME