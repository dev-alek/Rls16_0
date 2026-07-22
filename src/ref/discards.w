&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-dis-card


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_dis-card FOR ub.dis-card.
DEFINE BUFFER X_dis-host FOR ub.dis-host.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-dis-card
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник дисконтных карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/27/05
Author: Bakhtadze Natalya
Creation date: 09/27/05

Author: Черных
Created: 26/08/98

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
define input parameter p-list-mode as character no-undo .
/*бывает {&all} - глобальные {&company} фирменные "client" все карты клиента card - все карты пула с одной и той же first-main-card */
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-first-main-card   like ub.dis-card.first-main-card no-undo .
define input parameter  cli-recid  as recid no-undo .
define output parameter rid-list    as  char no-undo . /* список recid'ов выбранных клиентов */

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник дисконтных карт" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/1bascur.i  }
{ gbl/getcntxt.i def }
{ gbl/usr-flt.i }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_dis-card no-lock where ~
                                  recid(pos_dis-card) = ~{&rec-recid~} no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи ДИСКОНТНАЯ КАРТА" skip~
                            string(if avail pos_dis-card ~
                                    then  substitute("Номер карты: &1" ~
                                                    , pos_dis-card.d-card) ~
                                    else "":U) skip ~
                            "Запись была добавлена (или изменена или удалена) -" skip ~
                            "и теперь не попадает в текущую выборку" ~
                            view-as alert-box WARNING. ~
                          end


&SCOPED-DEFINE sort-clmn_1 (mark-string ( INPUT RECID( X_dis-card), INPUT rid-list))
&SCOPED-DEFINE dyn_sort-clmn_1  substitute('dynamic-function(&1mark-string&1, recid(X_dis-card), &1&2&1)', ~{&double-quote~}, rid-list)
&scoped-define label-clmn_1 '*'
&SCOPED-DEFINE sort-clmn_2 X_dis-card.d-card
&scoped-define label-clmn_2 'Номер'
&SCOPED-DEFINE sort-clmn_3 X_clients.obj-name
&scoped-define label-clmn_3 'Название/ФИО'
&SCOPED-DEFINE sort-clmn_4 X_dis-card.issue-code
&scoped-define label-clmn_4 'Маг-н'
&SCOPED-DEFINE sort-clmn_5 X_dis-card.issue-date
&scoped-define label-clmn_5 'Выдано'
&SCOPED-DEFINE sort-clmn_6 get-dpcn(X_dis-card.d-card, X_dis-card.emitent-host-code, X_dis-card.type, input p-curr-host-code, input p-curr-obj-type, input p-curr-obj-code, input ~{&dc_prop_discount_d-pcnt~},  X_dis-card.d-pcnt, X_dis-card.cash-d-pcnt, X_dis-card.category)
&SCOPED-DEFINE dyn_sort-clmn_6  substitute('dynamic-function(&1get-dpcn&1, X_dis-card.d-card,  X_dis-card.emitent-host-code, X_dis-card.type, &2, &1&3&1, &4, &1&5&1, X_dis-card.d-pcnt, X_dis-card.cash-d-pcnt, X_dis-card.category)', ~{&double-quote~}, p-curr-host-code,  p-curr-obj-type, p-curr-obj-code, ~{&dc_prop_discount_d-pcnt~})
&scoped-define label-clmn_6 'Скидка на!товар'
&SCOPED-DEFINE sort-clmn_7 X_dis-card.status_
&scoped-define label-clmn_7 'Статус'
&SCOPED-DEFINE sort-clmn_8 X_dis-card.emitent-host-code
&scoped-define label-clmn_8 'Фирма'
&SCOPED-DEFINE sort-clmn_9 X_dis-card.sourceD-card
&scoped-define label-clmn_9 'Перевыпуск'
&SCOPED-DEFINE sort-clmn_10 X_dis-card.overissue-num
&scoped-define label-clmn_10 '#'
&SCOPED-DEFINE sort-clmn_11 X_dis-card.first-main-card
&scoped-define label-clmn_11 'Перв.осн.'
&SCOPED-DEFINE sort-clmn_12 obj-d-pcnt
&scoped-define label-clmn_12 'Скидка на!объекте'
&SCOPED-DEFINE sort-clmn_13 X_dis-card.valid-date
&scoped-define label-clmn_13 'Действ.по'
&SCOPED-DEFINE sort-clmn_14 X_dis-card.type
&scoped-define label-clmn_14 'Тип'
&SCOPED-DEFINE sort-clmn_15 X_dis-card.credit-card
&scoped-define label-clmn_15 'Кред.?'
&SCOPED-DEFINE sort-clmn_16 X_dis-card.lim-kr
&scoped-define label-clmn_16 'Лимит кредита!(в вал.продаж)'
&SCOPED-DEFINE sort-clmn_17 (X_dis-card.cli-type + ' ' + STRING (X_dis-card.cli-code))
&scoped-define label-clmn_17 'Клиент'
&SCOPED-DEFINE sort-clmn_18 Get-num-chk-l(input rs-val, input pravo, input X_dis-host.num-chk, input X_dis-card.type, input X_dis-card.emitent-host-code, input v-cntxt-db-num)
&SCOPED-DEFINE dyn_sort-clmn_18  substitute('dynamic-function(&1Get-num-chk-l&1, &1&2&1, &3, X_dis-host.num-chk, &1X_dis-card.type&1, X_dis-card.emitent-host-code, input &4)', ~{&double-quote~}, rs-val, pravo, v-cntxt-db-num)
&scoped-define label-clmn_18 'Кол-во!чеков'
&SCOPED-DEFINE sort-clmn_19 Get-gds-sum-l(input rs-val, input pravo, X_dis-host.gds-tot-rubl, X_dis-host.gds-tot-base)
&SCOPED-DEFINE dyn_sort-clmn_19  substitute('dynamic-function(&1Get-gds-sum-l&1, &1&2&1, &3, X_dis-host.gds-tot-rubl, X_dis-host.gds-tot-base)', ~{&double-quote~}, rs-val, pravo)
&scoped-define label-clmn_19 'Сумма покупок'
&SCOPED-DEFINE sort-clmn_20 Get-disc-sum-l(input rs-val, input pravo, X_dis-host.gds-dis-rubl, X_dis-host.gds-dis-base)
&SCOPED-DEFINE dyn_sort-clmn_20  substitute('dynamic-function(&1Get-disc-sum-l&1, &1&2&1, &3, X_dis-host.gds-dis-rubl, X_dis-host.gds-dis-base)', ~{&double-quote~}, rs-val, pravo)
&scoped-define label-clmn_20 'Скидка'
&SCOPED-DEFINE sort-clmn_21 Get-netto-sum-l(input rs-val, input pravo, X_dis-host.gds-tot-rubl, X_dis-host.gds-tot-base, X_dis-host.gds-dis-rubl, X_dis-host.gds-dis-base)
&SCOPED-DEFINE dyn_sort-clmn_21  substitute('dynamic-function(&1Get-netto-sum-l&1, &1&2&1, &3, X_dis-host.gds-tot-rubl, X_dis-host.gds-tot-base, X_dis-host.gds-dis-rubl, X_dis-host.gds-dis-base)', ~{&double-quote~}, rs-val, pravo)
&scoped-define label-clmn_21 'Сумма покупок!нетто'
&SCOPED-DEFINE sort-clmn_22 Get-credit-sum-l(input rs-val, input pravo, X_dis-host.gds-tot-rubl, X_dis-host.gds-tot-base, X_dis-host.gds-dis-rubl, X_dis-host.gds-dis-base, X_dis-host.pay-tot-rubl, X_dis-host.pay-tot-base)
&SCOPED-DEFINE dyn_sort-clmn_22  substitute('dynamic-function(&1Get-credit-sum-l&1, &1&2&1, &3, X_dis-host.gds-tot-rubl, X_dis-host.gds-tot-base, X_dis-host.gds-dis-rubl, X_dis-host.gds-dis-base, X_dis-host.pay-tot-rubl, X_dis-host.pay-tot-base)', ~{&double-quote~}, rs-val, pravo)
&scoped-define label-clmn_22 'Сумма в кредит'
&SCOPED-DEFINE sort-clmn_23 get-dpcn( X_dis-card.d-card, X_dis-card.emitent-host-code, X_dis-card.type, input p-curr-host-code, input p-curr-obj-type, input p-curr-obj-code, input ~{&dc_prop_discount_cash-d-pcnt~}, X_dis-card.d-pcnt, X_dis-card.cash-d-pcnt, X_dis-card.category)
&SCOPED-DEFINE dyn_sort-clmn_23  substitute('dynamic-function(&1get-dpcn&1, X_dis-card.d-card,  X_dis-card.emitent-host-code, X_dis-card.type, &2, &1&3&1, &4, &1&5&1, X_dis-card.d-pcnt, X_dis-card.cash-d-pcnt, X_dis-card.category)',  ~{&double-quote~}, p-curr-host-code, p-curr-obj-type, p-curr-obj-code, ~{&dc_prop_discount_cash-d-pcnt~})
&scoped-define label-clmn_23 'Скидка на!итог'
&SCOPED-DEFINE sort-clmn_24 ~{&dc-d-pcnt-name~}
&scoped-define label-clmn_24 'Использ.скидки'
&SCOPED-DEFINE sort-clmn_25 X_dis-card.is-subsid
&scoped-define label-clmn_25 'Дополн?'
&SCOPED-DEFINE sort-clmn_26 X_dis-card.main-card
&scoped-define label-clmn_26 'Основная'

/* Local Variable Definitions ---                                       */

define variable log-res as log no-undo.
define variable choice as log no-undo.
define variable ri-str  as char no-undo.
define variable ri          as      recid   no-undo     init ? .

define buffer b_clients for ub.clients.
define buffer b-d-c for ub.dis-card .
define variable filter-point-name as character no-undo .
define variable filter-point-name0 as character no-undo init "Дисконтные_карты" .
define variable filter-point as character no-undo .
define variable filter-point0 as character no-undo init "discards" .
define variable status-type as char no-undo.
define variable new-type as char no-undo init "".
define variable glob-val as logical no-undo init yes.
define variable v-glob-curr-code like ub.currency.curr-code no-undo .
define variable dopi as integer no-undo init -1.
define variable hist-option as character no-undo.
define variable add-option as character no-undo .
define variable chk-option as character no-undo .
define variable LOOKUP-option as character no-undo .
define variable obj-d-pcnt like ub.dis-card.d-pcnt no-undo.
define variable obj-cash-d-pcnt like ub.dis-card.cash-d-pcnt no-undo.
define variable v-is-dc as character no-undo .
define variable v-is-ef as character no-undo .
define variable v-conf-type as character no-undo .
define variable attr-option as character no-undo .
define variable prop-option as character no-undo .
define variable disc-option as character no-undo .
define variable glog as logical no-undo .
define variable v-host-name as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
DEFINE VARIABLE v-cli-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cli-type-code AS CHARACTER NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-initial-height as decimal no-undo .
define buffer pos_dis-card for ub.dis-card.

{ ref/get-dpcn.i }
{ gbl/fltfield.i }
{ ref/discards.i }

&SCOP dc-d-pcnt-code string(X_dis-card.d-pcnt-method)

&scop first-main-card-label "Перв.осн."
&scop client-label "Клиент"
&scop host-label "По фирме"
&scop global-label "Глоб."

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-dis-card
&Scoped-define BROWSE-NAME br-discard

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_dis-card X_clients X_dis-host

/* Definitions for BROWSE br-discard                                    */
&Scoped-define FIELDS-IN-QUERY-br-discard {&sort-clmn_1} {&sort-clmn_2} {&sort-clmn_3} @ V-CLI-NAME {&sort-clmn_4} {&sort-clmn_5} {&sort-clmn_6} {&sort-clmn_7} {&sort-clmn_8} {&sort-clmn_9} {&sort-clmn_10} {&sort-clmn_11} {&sort-clmn_13} {&sort-clmn_14} {&sort-clmn_15} {&sort-clmn_16} {&sort-clmn_17} @ V-CLI-TYPE-CODE {&sort-clmn_18} {&sort-clmn_19} {&sort-clmn_20} {&sort-clmn_21} {&sort-clmn_22} {&sort-clmn_23} {&sort-clmn_24} {&sort-clmn_25} {&sort-clmn_26}
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-discard {&sort-clmn_5}
&Scoped-define SELF-NAME br-discard
&Scoped-define QUERY-STRING-br-discard FOR EACH X_dis-card NO-LOCK WHERE         X_dis-card.emitent-host-code = p-curr-host-code     FIRST X_clients NO-LOCK WHERE          X_clients.obj-type = X_dis-car.cli-type     AND X_clients.obj-code = X_dis-car.cli-code, ~
           FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = X_dis-card.emitent-host-code      AND X_dis-host.d-card = X_dis-card.d-card      BY X_dis-card.d-card INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-discard OPEN QUERY {&SELF-NAME} FOR EACH X_dis-card NO-LOCK WHERE         X_dis-card.emitent-host-code = p-curr-host-code     FIRST X_clients NO-LOCK WHERE          X_clients.obj-type = X_dis-car.cli-type     AND X_clients.obj-code = X_dis-car.cli-code, ~
           FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = X_dis-card.emitent-host-code      AND X_dis-host.d-card = X_dis-card.d-card      BY X_dis-card.d-card INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-discard X_dis-card X_clients X_dis-host
&Scoped-define FIRST-TABLE-IN-QUERY-br-discard X_dis-card
&Scoped-define SECOND-TABLE-IN-QUERY-br-discard X_clients
&Scoped-define THIRD-TABLE-IN-QUERY-br-discard X_dis-host


/* Definitions for DIALOG-BOX d-dis-card                                */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-dis-card ~
    ~{&OPEN-QUERY-br-discard}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-mark b-sel b-add b-lkp b-chg b-del ~
b-chk b-disc b-print B-sch b-history b-help B-prop B-type b-payment b-view ~
b_clientsi RS-global b-sl RS-SEARCH SPattern RS-val br-discard mark-num ~
t-totals F-gds-sum F-netto-sum F-credit-sum F-num-chk F-disc-sum F-pay-sum ~
F-saldo-sum
&Scoped-Define DISPLAYED-OBJECTS RS-global RS-SEARCH SPattern RS-val ~
mark-num t-totals F-gds-sum F-netto-sum F-credit-sum F-num-chk F-disc-sum ~
F-pay-sum F-saldo-sum

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-add
       MENU-ITEM m_glob         LABEL "Глобальная"
       MENU-ITEM m_company      LABEL "По фирме"
       MENU-ITEM m_cli-sourced  LABEL "Перевыпустить"
       MENU-ITEM m_cli-subsid   LABEL "Дополнительная"
       RULE
       MENU-ITEM m_dct-client   LABEL "Клиент-Счет"   .

DEFINE MENU MENU-b-add-copy
       MENU-ITEM m_add          LABEL "Добавить"
       MENU-ITEM m_copy         LABEL "Копировать"
       MENU-ITEM m_sourced      LABEL "Перевыпустить"
       MENU-ITEM m_subsid       LABEL "Дополнительная".

DEFINE MENU MENU-b-chk
       MENU-ITEM m_chk-doc      LABEL "Чеки"
       MENU-ITEM m_ef-cd-trans  LABEL "Транзакции EasyFuel".

DEFINE MENU MENU-b-disc
       MENU-ITEM m_lookup-disc  LABEL "Просмотр"
       MENU-ITEM m_update-disc  LABEL "Изменение"     .

DEFINE MENU MENU-b-history
       MENU-ITEM m_c-dc-hist    LABEL "По одной карте"
       MENU-ITEM m_c-dc-hist_plus LABEL "С учетом перевыпуска карт".

DEFINE MENU MENU-b-lkp
       MENU-ITEM m_one          LABEL "Карта"
       MENU-ITEM m_first-main-card LABEL "Пул карт"      .

DEFINE MENU MENU-B-prop
       MENU-ITEM m_lookup-prop  LABEL "Просмотр"
       MENU-ITEM m_update-prop  LABEL "Изменение"     .

DEFINE MENU POPUP-MENU-b-del
       MENU-ITEM m-curr         LABEL "Текущий"
       MENU-ITEM m-del          LABEL "Удалить"
       MENU-ITEM m-block        LABEL "Блокирован"    .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chk
     LABEL "Ч&еки"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Статус"
     SIZE 10 BY 1.

DEFINE BUTTON b-disc
     LABEL "&Скидки"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

DEFINE BUTTON b-history
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-payment
     LABEL "Плате&жи"
     SIZE 10 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 3 BY 1.

DEFINE BUTTON B-prop
     LABEL "Свойства"
     SIZE 10 BY 1.

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-sl
     LABEL "Стопл-ты"
     SIZE 10 BY 1.

DEFINE BUTTON B-type
     LABEL "Тип &карты"
     SIZE 10 BY 1.

DEFINE BUTTON b-view
     LABEL "&Архив"
     SIZE 10 BY 1.

DEFINE BUTTON b_clientsi
     LABEL "&Клиент"
     SIZE 10 BY 1.

DEFINE VARIABLE F-credit-sum AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "В кредит"
      VIEW-AS TEXT
     SIZE 16.6 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE F-disc-sum AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Скидки"
      VIEW-AS TEXT
     SIZE 16.6 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE F-gds-sum AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Покупки"
      VIEW-AS TEXT
     SIZE 16.6 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE F-netto-sum AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Нетто"
      VIEW-AS TEXT
     SIZE 16.6 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE F-num-chk AS INTEGER FORMAT "->>>>>9":U INITIAL 0
     LABEL "Чеков"
      VIEW-AS TEXT
     SIZE 8 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE F-pay-sum AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Платежи"
      VIEW-AS TEXT
     SIZE 16.6 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.

DEFINE VARIABLE F-saldo-sum AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Баланс"
      VIEW-AS TEXT
     SIZE 16.6 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4.8 BY .77
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE SPattern AS CHARACTER FORMAT "X(256)":U
     LABEL "Поиск"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE t-totals AS CHARACTER FORMAT "X(256)":U INITIAL "Итоги по всем картам клиента"
      VIEW-AS TEXT
     SIZE 55 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-global AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", "1",
"2", "2",
"3", "3"
     SIZE 37 BY .93 NO-UNDO.

DEFINE VARIABLE RS-SEARCH AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", "1",
"2", "2",
"3", "3"
     SIZE 26.9 BY 1 NO-UNDO.

DEFINE VARIABLE RS-val AS CHARACTER INITIAL "rubl"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "abbr_rubli_firstshift", "rubl",
"Баз.вал.", "base"
     SIZE 19.6 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-discard FOR
                X_dis-card,
                X_clients,
                X_dis-host SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-discard
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-discard d-dis-card _FREEFORM
  QUERY br-discard NO-LOCK DISPLAY
      {&sort-clmn_1} COLUMN-LABEL {&label-clmn_1} FORMAT "x(1)":U
{&sort-clmn_2} COLUMN-LABEL {&label-clmn_2} FORMAT "X(19)":U
{&sort-clmn_3} @ V-CLI-NAME COLUMN-LABEL {&label-clmn_3} FORMAT "x(29)":U
{&sort-clmn_4} COLUMN-LABEL {&label-clmn_4} FORMAT "99999":U
{&sort-clmn_5} COLUMN-LABEL {&label-clmn_5} FORMAT "99/99/9999":U
{&sort-clmn_6} COLUMN-LABEL {&label-clmn_6} FORMAT "X(11)":U
{&sort-clmn_7} COLUMN-LABEL {&label-clmn_7} FORMAT "X(4)":U
{&sort-clmn_8} COLUMN-LABEL {&label-clmn_8} FORMAT ">>>>>99999":U
{&sort-clmn_9} COLUMN-LABEL {&label-clmn_9} FORMAT "X(19)":U
{&sort-clmn_10} COLUMN-LABEL {&label-clmn_10} FORMAT ">9":U
{&sort-clmn_11} COLUMN-LABEL {&label-clmn_11} FORMAT "X(19)":U
{&sort-clmn_13} COLUMN-LABEL {&label-clmn_13} FORMAT "99/99/9999":U
{&sort-clmn_14} COLUMN-LABEL {&label-clmn_14} FORMAT "X(8)":U
{&sort-clmn_15} COLUMN-LABEL {&label-clmn_15} FORMAT "+/":U
{&sort-clmn_16} COLUMN-LABEL {&label-clmn_16} FORMAT ">>>,>>>,>>>,>>9.99":U
{&sort-clmn_17} @ V-CLI-TYPE-CODE COLUMN-LABEL {&label-clmn_17} FORMAT "X(12)":U
{&sort-clmn_18} COLUMN-LABEL {&label-clmn_18} FORMAT "->>>>>>>>>>>9"
{&sort-clmn_19} COLUMN-LABEL {&label-clmn_19} FORMAT "->>,>>>,>>>,>>9.99"
{&sort-clmn_20} COLUMN-LABEL {&label-clmn_20} FORMAT "->>>,>>>,>>9.99"
{&sort-clmn_21} COLUMN-LABEL {&label-clmn_21} FORMAT "->>>,>>>,>>9.99"
{&sort-clmn_22} COLUMN-LABEL {&label-clmn_22} FORMAT "->>>,>>>,>>9.99"
{&sort-clmn_23} COLUMN-LABEL {&label-clmn_23} FORMAT "X(11)":U
{&sort-clmn_24} COLUMN-LABEL {&label-clmn_24} FORMAT "X(13)":U
{&sort-clmn_25} COLUMN-LABEL {&label-clmn_25} FORMAT "+/":U
{&sort-clmn_26} COLUMN-LABEL {&label-clmn_26} FORMAT "X(19)":U
ENABLE
{&sort-clmn_5}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.03
         BGCOLOR 15 FGCOLOR 0 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-dis-card
     b-exit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     b-add AT ROW 1 COL 24
     b-lkp AT ROW 1 COL 34
     b-chg AT ROW 1 COL 44
     b-del AT ROW 1 COL 54
     b-chk AT ROW 1 COL 64
     b-disc AT ROW 1 COL 74 WIDGET-ID 6
     b-print AT ROW 1 COL 86
     B-sch AT ROW 1 COL 89
     b-history AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     B-prop AT ROW 2 COL 39 WIDGET-ID 4
     B-type AT ROW 2 COL 59
     b-payment AT ROW 2 COL 69
     b-view AT ROW 2 COL 79
     b_clientsi AT ROW 2 COL 89
     RS-global AT ROW 2.07 COL 1 NO-LABEL
     b-sl AT ROW 3 COL 89 WIDGET-ID 8
     RS-SEARCH AT ROW 3.27 COL 4 NO-LABEL
     SPattern AT ROW 3.27 COL 36.6 COLON-ALIGNED
     RS-val AT ROW 3.47 COL 59 NO-LABEL
     br-discard AT ROW 4.63 COL 1
     mark-num AT ROW 3.33 COL 2.5 NO-LABEL
     t-totals AT ROW 19.93 COL 20.1 COLON-ALIGNED NO-LABEL
     F-gds-sum AT ROW 20.93 COL 8 COLON-ALIGNED
     F-netto-sum AT ROW 20.93 COL 35 COLON-ALIGNED
     F-credit-sum AT ROW 20.93 COL 64 COLON-ALIGNED
     F-num-chk AT ROW 20.93 COL 88 COLON-ALIGNED
     F-disc-sum AT ROW 22.2 COL 8 COLON-ALIGNED
     F-pay-sum AT ROW 22.2 COL 35 COLON-ALIGNED
     F-saldo-sum AT ROW 22.2 COL 64 COLON-ALIGNED
     SPACE(16.40) SKIP(0.42)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дисконтные карты":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_dis-card B "?" ? ub dis-card
      TABLE: X_dis-host B "?" ? ub dis-host
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-dis-card
   FRAME-NAME                                                           */
/* BROWSE-TAB br-discard RS-val d-dis-card */
ASSIGN
       FRAME d-dis-card:SCROLLABLE       = FALSE
       FRAME d-dis-card:PRIVATE-DATA     =
                "DLGCLOSE".

ASSIGN
       b-add:POPUP-MENU IN FRAME d-dis-card       = MENU MENU-b-add:HANDLE.

ASSIGN
       b-chg:POPUP-MENU IN FRAME d-dis-card       = MENU MENU-b-add-copy:HANDLE.

ASSIGN
       b-chk:POPUP-MENU IN FRAME d-dis-card       = MENU MENU-b-chk:HANDLE.

ASSIGN
       b-del:POPUP-MENU IN FRAME d-dis-card       = MENU POPUP-MENU-b-del:HANDLE.

ASSIGN
       b-disc:POPUP-MENU IN FRAME d-dis-card       = MENU MENU-b-disc:HANDLE.

ASSIGN
       b-history:POPUP-MENU IN FRAME d-dis-card       = MENU MENU-b-history:HANDLE.

ASSIGN
       b-lkp:POPUP-MENU IN FRAME d-dis-card       = MENU MENU-b-lkp:HANDLE.

ASSIGN
       B-prop:POPUP-MENU IN FRAME d-dis-card       = MENU MENU-B-prop:HANDLE.

ASSIGN
       br-discard:NUM-LOCKED-COLUMNS IN FRAME d-dis-card     = 2.

/* SETTINGS FOR FILL-IN mark-num IN FRAME d-dis-card
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-discard
/* Query rebuild information for BROWSE br-discard
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH X_dis-card NO-LOCK WHERE
        X_dis-card.emitent-host-code = p-curr-host-code
    FIRST X_clients NO-LOCK WHERE
         X_clients.obj-type = X_dis-car.cli-type
    AND X_clients.obj-code = X_dis-car.cli-code,
    FIRST X_dis-host NO-LOCK WHERE
         X_dis-host.host-code = X_dis-card.emitent-host-code
     AND X_dis-host.d-card = X_dis-card.d-card
     BY X_dis-card.d-card INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-discard FOR
                X_dis-card,
                X_clients,
                X_dis-host SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-discard */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-dis-card
ON CHOOSE OF b-add IN FRAME d-dis-card /* Добавить */
DO:
define buffer b-dis-card for ub.dis-card .
define buffer for-clients for ub.clients.
define variable old-list-mode as char no-undo.
DEFINE VARIABLE varhost-code like ub.sysconf.host-code no-undo .

  define variable v-ok as logical no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_referense-dis_input-deletion-updating':U
    {&cntxt-firm}
    p-curr-host-code
    '':U
    0
    0
    0
    0
    true
    v-ok
  }
  if v-ok <> true
  then do:
    undo, return no-apply .
  end.


if new-type = ""
and add-option = "":U
then  run gbl/pop-up.p ( input self:handle, input no) no-error.
if add-option = {&add-copy}
or add-option = ({&update} + {&comma-char} + {&add-copy})
or add-option = ({&add-def} + {&comma-char} + {&add-copy})
then do:
  if not available X_dis-card then do:
    message
    "Выберите карту для копирования, перевыпуска или выпуска дополн. карты"
    view-as alert-box .
    assign
    add-option = "":u.
    return no-apply.
  end.
  assign
  ri = recid(X_dis-card)
  varhost-code = X_dis-card.emitent-host-code
  .
end.
if p-list-mode = "client":u then do:
  assign
  cli-recid = recid(b_clients).
end.
if add-option = ({&update} + {&comma-char} + {&add-copy}) then do:
  /*
  find first X_clients no-lock where
            X_clients.obj-type = X_dis-card.cli-type
        AND X_clients.obj-code = X_dis-card.cli-code no-error .
  if not available X_clients then do:
    message
    substitute("Нет клиента  &1&2 для ДК &3"
               , X_dis-card.cli-type
               , X_dis-card.cli-code
               , X_dis-card.d-card)
    view-as alert-box error .
    return no-apply.

  end.
  */
  assign
  cli-recid = recid(X_clients).
end.

old-list-mode = p-list-mode.
if old-list-mode <> "client"
and add-option <> ({&update} + {&comma-char} + {&add-copy})
then do:
  assign
  ri-str = "".
  run ref/cli-all.w (
                  input parparentproc
                ,input "b-sel,b-add"
                ,input {&prs}
                ,input {&all}
                ,input {&all}
                ,input ?
                ,input  ",,,,,,NO"
                ,input ?
                ,output ri-str ) .
  if ri-str <> "" then do:
          cli-recid = integer( ri-str ).
  end.
  else return no-apply.
end.
FIND for-clients WHERE recid( for-clients ) = cli-recid NO-LOCK .
if NOT for-clients.stts = 0 then do:
  message
  "Нельзя создавать дисконтные карты для удаленных клиентов!"
  view-as alert-box ERROR.
  return no-apply.
end.
if add-option = ({&update} + {&comma-char} + {&add-copy})
or for-clients.obj-type = {&prs}
or for-clients.obj-type = {&cmp}
then do:
  if old-list-mode = "client":u then
  p-list-mode = new-type.
  else do:
    p-list-mode = old-list-mode.
  end.
  assign
  varhost-code = (if p-list-mode = {&company}
                  then p-curr-host-code
                  else (if p-list-mode = {&all} then 0 else -1))
  varhost-code = (if add-option = {&dct-client} then 0 else varhost-code)
  .

  run ref/dcardi.w (
                input parparentproc
              , input  (if add-option = "":U
                 then {&add-def}
                 else add-option)
              , input varhost-code
              , input p-curr-host-code
              , input p-curr-obj-type
              , input p-curr-obj-code
              , input cli-recid
              , input-output ri ) no-error .
  assign
  add-option = "":U.
  if ri <> ? then do: /* ri = recid( X_dis-card ) */
    run OpenBr in this-procedure ( input yes, input no, input no).
    reposition br-discard to recid ri no-error.
    if error-status:error then do:
&scop rec-recid ri
      {&cant-positioning}.
    end.
    if available X_dis-card then do:
        log-res = br-discard:select-focused-row( ).
    end.
  end.
end.
else do:
  message
  "Дисконтные карты выдаются" skip
  "только внешним контрагентам."
  view-as alert-box INFORMATION .
end.
apply "entry" to br-discard.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg d-dis-card
ON CHOOSE OF b-chg IN FRAME d-dis-card /* Изменить */
DO:
    define variable old-d-pcnt like ub.dis-card.d-pcnt no-undo.
    define variable v-ok as logical no-undo .
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_referense-dis_input-deletion-updating':U
      {&cntxt-firm}
      p-curr-host-code
      '':U
      0
      0
      0
      0
      true
      v-ok
    }
    if v-ok <> true
    then do:
      undo, return no-apply .
    end.

    if available X_dis-card THEN do:
        if X_dis-card.emitent-host-code <> p-curr-host-code and X_dis-card.emitent-host-code <> 0 then do:
            message "Данная дисконтная карта принадлежит другой фирме!" skip
                            "изменение запрещено" view-as alert-box ERROR.
                            return no-apply.
        end.
        ri = recid( X_dis-card ) .
        old-d-pcnt = X_dis-card.d-pcnt.
        run ref/dcardi.w (
                       input parparentproc
                     , input  {&update}
                     , input X_dis-card.emitent-host-code
                     , input p-curr-host-code
                     , input p-curr-obj-type
                     , input p-curr-obj-code
                     , input ?
                     , input-output ri ) .
        if ri <> ? then do:
            run OpenBr in this-procedure ( input yes, input no, input no).
            reposition br-discard to recid ri no-error.
            if error-status:error then do:
                &scop rec-recid ri
                {&cant-positioning}.
            end.
            if available X_dis-card then do:
               log-res = br-discard:select-focused-row( ).
            end.
        end.
    end.
    apply "entry" to br-discard.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chk d-dis-card
ON CHOOSE OF b-chk IN FRAME d-dis-card /* Чеки */
DO:
DEFINE VARIABLE varrid-list as character no-undo .
IF NOT AVAILABLE X_DIS-CARD THEN RETURN NO-APPLY.
IF chk-OPTION = '':u THEN DO:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
END.
IF chk-OPTION = '':u THEN RETURN NO-APPLY.

CASE chk-OPTION:
  WHEN "chk-docs" THEN DO:
    run str/chk-docs.w (
                    input parparentproc
                    ,input '':U
                    ,input "d-card":U
                    ,input ?
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input '':U
                    ,input X_dis-card.d-card
                    ,input 0
                    ,input ?
                    ,input ?
                    ,input 0
                    ,output varrid-list) no-error.
  end.
  when "ef" then do:
    run str/cd-trans.w (
                        input parparentproc
                       ,input "" /*bttns  */
                       ,input "charkey_one" /*p-list-mode*/
                       ,input integer({&cdt-ach}) /*p-trans-type */
                       ,input p-curr-obj-type
                       ,input p-curr-obj-code
                       ,input 01/01/2008 /*p-start-date */
                       ,input {&end-of-age} /*p-end-date */
                       ,input X_dis-card.d-card /*p-charkey-one */
                       ,input "" /*p-trans-id-chr*/
                       ,output varrid-list    ) no-error.
  end.
end case.
chk-option = "".
apply "entry" to br-discard.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-dis-card
ON CHOOSE OF b-del IN FRAME d-dis-card /* Статус */
DO:
define variable ok-restore as logical no-undo .
  define variable v-ok as logical no-undo .
if X_dis-card.status_  = {&deleted-status} then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_referense-dis_current-status':U
      {&cntxt-firm}
      p-curr-host-code
      '':U
      0
      0
      0
      0
      true
      ok-restore
      no-error
    }
    if ok-restore <> true
    then do:
      undo, return no-apply .
    end.
  end.
  else do:
      { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_referense-dis_input-deletion-updating':U
      {&cntxt-firm}
      p-curr-host-code
      '':U
      0
      0
      0
      0
      true
      v-ok
      no-error
    }
    if v-ok <> true
    then do:
      undo, return no-apply .
    end.
  end.

    if status-type = "" then do:
        run gbl/pop-up.p ( input b-del:handle, input no) no-error.
    end.
    if error-status:error or status-type = "" or not avail X_dis-card then do:
      status-type = "":U.
      return no-apply.
    end.
    assign
    ri = recid(X_dis-card).
    run ref/dcardi02.p (
                    input parparentproc
                   ,input recid(X_dis-card)
                   ,input no    /*p-silent*/
                   ,input ok-restore
                   ,input '':U /*p-mode2*/
                   ,input '':U /*p-source-type*/
                   ,input '':U /*p-source-ref*/
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,input-output status-type) no-error.
    if not error-status:error then do:
      run OpenBr in this-procedure ( input yes, input no, input no).
      REPOSITION br-discard to recid ri No-error.
    if error-status:error then do:
&scop rec-recid ri
      {&cant-positioning}.
    end.
      if available X_dis-card then do:
        log-res = br-discard:select-focused-row( ).
      end.
    end.
    apply "ENTRY" to br-discard.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-disc d-dis-card
ON CHOOSE OF b-disc IN FRAME d-dis-card /* Скидки */
DO:
if disc-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if disc-option = "":U then do:
      return no-apply.
  end.
  RUN proc-b-disc IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history d-dis-card
ON CHOOSE OF b-history IN FRAME d-dis-card /* История */
DO:
  if not avail X_dis-card then return no-apply.
  if hist-option = '':U then do:
        run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if hist-option = '':U then return no-apply.
  run proc-b-history in this-procedure ( input hist-option) no-error.
  if error-status:error then do:
    hist-option = '':U.
    return no-apply.
  end.
  APPLY "ENTRY" to br-discard.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp d-dis-card
ON CHOOSE OF b-lkp IN FRAME d-dis-card /* Просмотр */
DO:
define variable old-d-pcnt like X_dis-card.d-pcnt no-undo.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
IF NOT AVAILABLE X_DIS-CARD THEN RETURN NO-APPLY.
IF LOOKUP-OPTION = '':u THEN DO:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
END.
IF LOOKUP-OPTION = '':u THEN RETURN NO-APPLY.

CASE LOOKUP-OPTION:
  WHEN {&lookup} THEN DO:
    if X_dis-card.emitent-host-code <> p-curr-host-code and X_dis-card.emitent-host-code <> 0 then do:
       message
       "Данная дисконтная карта принадлежит другой фирме!" skip
       "ПРОСМОТР запрещен" view-as alert-box ERROR.
       return no-apply.
    end.
    ri = recid( X_dis-card ) .
    run ref/dcardi.w (
                  input parparentproc
                , input {&lookup}
                , input X_dis-card.emitent-host-code
                , input p-curr-host-code
                , input p-curr-obj-type
                , input p-curr-obj-code
                , input ?
                , input-output ri ) NO-ERROR.

  END.
  WHEN "first-main-card" THEN DO:
     run ref/discards.w (
                    input parparentproc
                   ,input  "":U
                   ,input "card":u
                   ,input p-curr-host-code
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,input X_dis-card.first-main-card
                   ,input ?
                   ,output v-rid-list ) no-error .

  END.
END CASE.
LOOKUP-OPTION = '':u.
apply "entry" to br-discard.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-dis-card
ON CHOOSE OF b-mark IN FRAME d-dis-card /* * */
DO:
    if available X_dis-card then do:
     { gbl/markstrn.i X_dis-card rid-list }
      glog = br-discard:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
        glog = br-discard:select-next-row ().
        apply "iteration-changed" to br-discard in frame {&frame-name}.
      end.
      if num-entries( rid-list ) = 0 then
          hide mark-num in frame {&frame-name}.
      else
          disp num-entries( rid-list ) @ mark-num with frame {&frame-name}.
    end.
    apply "entry" to br-discard in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-payment
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-payment d-dis-card
ON CHOOSE OF b-payment IN FRAME d-dis-card /* Платежи */
DO:
  define variable v-ok as logical no-undo .
  define variable v-is-credit as character no-undo .
  define variable v-is-fin as logical no-undo .
  define variable v-conf-type as character no-undo .
  define variable v-rid-list as character no-undo .
  define variable v-add as logical no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_payments-reference_lookup':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-ok
  }
  if v-ok <> true
  then do:
    undo, return no-apply .
  end.
  /*проверим карта кредитная? включен ли параметр кредит ? на текущей фирме?*/
  if available X_dis-card THEN  do:

    { gbl/conf-rd.i
      "'is-fin':u"
      "'':u"
      "'':u"
      0
      "'':u"
      "'':u"
      "'':u"
      no
      v-is-fin
      v-conf-type
      no-error
    }
    { gbl/conf-rd.i
    "'iscredit'"
    0
    "''":U
    0
    "''":U
    "''":U
    "''":U
    NO
    v-is-credit
    v-conf-type
    NO-ERROR
    }
    assign
    v-add = (X_dis-card.credit-card
            and X_dis-card.emitent-host-code <> 0
            and logical(v-is-credit) = yes
            /*and logical(v-is-fin) = no*/
            )
    no-error.
    run ref/payments.w (
                     input parparentproc
                    ,input (if v-add then "b-add" else '')
                    ,input {&card}
                    ,input ?
                    ,input ?
                    ,input ""
                    ,input ""
                    ,input X_dis-card.d-card
                    ,output v-rid-list) no-error .
  end.
  apply "entry" to br-discard.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-dis-card
ON CHOOSE OF b-print IN FRAME d-dis-card /* Печать */
DO:
    run ref/discardp.p (
                   input parparentproc
                  ,input frame {&frame-name}:title
                  ,input pravo
                  ,input rs-val
                  ,input p-curr-host-code
                  ,input p-curr-obj-type
                  ,input p-curr-obj-code
                  ,buffer X_dis-card
                  ,input query br-discard:handle
                    ) no-error.
    If error-status:error then do:
        return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prop d-dis-card
ON CHOOSE OF B-prop IN FRAME d-dis-card /* Свойства */
DO:
  if prop-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if prop-option = "":U then do:
      return no-apply.
  end.
  RUN proc-b-prop IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch d-dis-card
ON CHOOSE OF B-sch IN FRAME d-dis-card /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-dis-card
ON CHOOSE OF b-sel IN FRAME d-dis-card /* Выбор  */
DO:
    if ( available X_dis-card ) AND ( rid-list = "" ) then
        rid-list = string( recid( X_dis-card ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sl d-dis-card
ON CHOOSE OF b-sl IN FRAME d-dis-card /* Стопл-ты */
DO:
  define variable v-loc-rid-list as character no-undo .
  if not available X_dis-card then undo, return no-apply.
  run ref/stop-lls.w ( INPUT parparentproc
                  ,INPUT "":U /*btnns*/
                  ,INPUT {&LOOKUP}
                  ,INPUT '':U /*p-stop-list-code*/
                  ,input X_dis-card.d-card /*p-d-card*/
                  ,INPUT-OUTPUT v-loc-rid-list ) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-type d-dis-card
ON CHOOSE OF B-type IN FRAME d-dis-card /* Тип карты */
DO:
define variable dctype-ri as recid no-undo.
  if not avail X_dis-card then return no-apply.
    FIND FIRST ub.dis-card-type No-LOCK WHERE
                ub.dis-card-type.type = X_dis-card.type AND
                ub.dis-card-type.emitent-host-code = X_dis-card.emitent-host-code AND
                ub.dis-card-type.host-code = 0 and
                ub.dis-card-type.obj-type = "":U and
                ub.dis-card-type.obj-code = 0 No-ERROR.
     if not avail ub.dis-card-type then do:
        message "Неверный тип дисконтной карты"
        view-as alert-box ERROR.
        return no-apply.
     end.
     dctype-ri = recid( ub.dis-card-type ) .
     run ref/dc-typei.w (
                    input parparentproc
                   ,input {&lookup}
                   ,input p-curr-host-code
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,input-output dctype-ri ).
     apply "ENTRY" to br-discard.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-view
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-view d-dis-card
ON CHOOSE OF b-view IN FRAME d-dis-card /* Архив */
DO:
define buffer b-dis-card for ub.dis-card .
define variable rc as recid.
define variable old-d-pcnt like ub.dis-card.d-pcnt.
define variable old-val as character no-undo .
if available X_dis-card then  do:
  rc = recid(X_dis-card).
  if X_dis-card.emitent-host-code = p-curr-host-code or X_dis-card.emitent-host-code = 0 then do:
      old-d-pcnt = X_dis-card.d-pcnt.
      old-val = rs-val.
      run ref/dc-view.w ( input parparentproc
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input X_dis-card.d-card
                    ,input (if p-list-mode = "card" then no else ?) /*t-legacy*/
                    ,input (if p-list-mode = "card" then no else ?) /*t-subsid*/
                    ) .
      rs-val = old-val.
      DISPLAY RS-val with frame {&frame-name}.
      run OpenBR in this-procedure ( input yes, input no, input no).
      REPOSITION br-discard to recid rc NO-ERROR.
    if error-status:error then do:
    &scop rec-recid rc
    {&cant-positioning}.
    end.
  end.
  else do:
      message "Данная дисконтная карта принадлежит другой фирме - просмотр запрещен!"
      view-as alert-box ERROR.
  end.
end.
apply "entry" to br-discard.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-discard
&Scoped-define SELF-NAME br-discard
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-discard d-dis-card
ON DEFAULT-ACTION OF br-discard IN FRAME d-dis-card
DO:
    if b-sel:sensitive THEN
        apply "CHOOSE":U to b-sel.
    else
        apply "CHOOSE":U to b-view.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-discard d-dis-card
ON ITERATION-CHANGED OF br-discard IN FRAME d-dis-card
DO:
    if available X_dis-card then
        log-res = br-discard:select-focused-row( ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-discard d-dis-card
ON LEFT-MOUSE-DBLCLICK OF br-discard IN FRAME d-dis-card
DO:
    apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-discard d-dis-card
ON RETURN OF br-discard IN FRAME d-dis-card
DO:
    apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b_clientsi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_clientsi d-dis-card
ON CHOOSE OF b_clientsi IN FRAME d-dis-card /* Клиент */
DO:

define variable cli-ri as recid init ? no-undo .

    if available X_dis-card THEN do:
            run ref/showcli.p (
             input parparentproc
            ,input X_dis-card.cli-type /* p-obj-type */
            ,input X_dis-card.cli-code /* p-obj-code */
            ).
        end.
    apply "entry" to br-discard.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-block
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-block d-dis-card
ON CHOOSE OF MENU-ITEM m-block /* Блокирован */
DO:
    status-type = {&blocked-status}.
    apply "choose" to b-del in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-curr d-dis-card
ON CHOOSE OF MENU-ITEM m-curr /* Текущий */
DO:
    status-type = {&current-status}.
    apply "choose" to b-del in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-del d-dis-card
ON CHOOSE OF MENU-ITEM m-del /* Удалить */
DO:
    status-type = {&deleted-status}.
    apply "choose" to b-del in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_add d-dis-card
ON CHOOSE OF MENU-ITEM m_add /* Добавить */
DO:
   assign
   new-type = "":U
   add-option = {&add-def}.
  apply "CHOOSE" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_c-dc-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_c-dc-hist d-dis-card
ON CHOOSE OF MENU-ITEM m_c-dc-hist /* По одной карте */
DO:
      assign
  hist-option = 'c-dc-hist':U.
  APPLY "CHOOSE" to b-history in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_c-dc-hist_plus
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_c-dc-hist_plus d-dis-card
ON CHOOSE OF MENU-ITEM m_c-dc-hist_plus /* С учетом перевыпуска карт */
DO:
      assign
  hist-option = 'c-dc-hist-plus':U.
  APPLY "CHOOSE" to b-history in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_chk-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_chk-doc d-dis-card
ON CHOOSE OF MENU-ITEM m_chk-doc /* Чеки */
DO:
  ASSIGN chk-OPTION = "chk-docs".
  apply "CHOOSE" to b-chk in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cli-sourced
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cli-sourced d-dis-card
ON CHOOSE OF MENU-ITEM m_cli-sourced /* Перевыпустить */
DO:
  add-option = ({&update} + {&comma-char} + {&add-copy}).
  apply "CHOOSE" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_cli-subsid
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_cli-subsid d-dis-card
ON CHOOSE OF MENU-ITEM m_cli-subsid /* Дополнительная */
DO:
  add-option = ({&add-def} + {&comma-char} + {&add-copy}).
  apply "CHOOSE" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_company
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_company d-dis-card
ON CHOOSE OF MENU-ITEM m_company /* По фирме */
DO:
  new-type = {&company}.
  apply "CHOOSE" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_copy d-dis-card
ON CHOOSE OF MENU-ITEM m_copy /* Копировать */
DO:
   assign
   new-type = "":U
   add-option = {&add-copy}.
  apply "CHOOSE" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_dct-client
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_dct-client d-dis-card
ON CHOOSE OF MENU-ITEM m_dct-client /* Клиент-Счет */
DO:
   assign
   new-type = "":U
   add-option = {&dct-client}.
  apply "CHOOSE" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_ef-cd-trans
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ef-cd-trans d-dis-card
ON CHOOSE OF MENU-ITEM m_ef-cd-trans /* Транзакции EasyFuel */
DO:
  ASSIGN chk-OPTION = "ef".
  apply "CHOOSE" to b-chk in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_first-main-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_first-main-card d-dis-card
ON CHOOSE OF MENU-ITEM m_first-main-card /* Пул карт */
DO:
  ASSIGN LOOKUP-OPTION = "first-main-card".
  apply "CHOOSE" to b-LKP in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_glob
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_glob d-dis-card
ON CHOOSE OF MENU-ITEM m_glob /* Глобальная */
DO:
  new-type = {&all}.
  apply "CHOOSE" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup-disc d-dis-card
ON CHOOSE OF MENU-ITEM m_lookup-disc /* Просмотр */
DO:
  assign
  disc-option = {&LOOKUP}
  .
  RUN proc-b-disc IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    disc-option = '':U.
    RETURN NO-APPLY.
  end.
  disc-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup-prop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup-prop d-dis-card
ON CHOOSE OF MENU-ITEM m_lookup-prop /* Просмотр */
DO:
    assign
  prop-option = {&LOOKUP}
  .
  RUN proc-b-prop IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    prop-option = '':U.
    RETURN NO-APPLY.
  end.
  assign
  prop-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one d-dis-card
ON CHOOSE OF MENU-ITEM m_one /* Карта */
DO:
  ASSIGN LOOKUP-OPTION = {&LOOKUP}.
  apply "CHOOSE" to b-LKP in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_sourced
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_sourced d-dis-card
ON CHOOSE OF MENU-ITEM m_sourced /* Перевыпустить */
DO:
 assign
 new-type = "":U
 add-option =   {&update} + {&comma-char} + {&add-copy}.
apply "CHOOSE" to b-add in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_subsid
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_subsid d-dis-card
ON CHOOSE OF MENU-ITEM m_subsid /* Дополнительная */
DO:
  add-option = ({&add-def} + {&comma-char} + {&add-copy}).
  apply "CHOOSE" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update-disc d-dis-card
ON CHOOSE OF MENU-ITEM m_update-disc /* Изменение */
DO:
    assign
  disc-option = {&UPDATE}
  .
  RUN proc-b-disc IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    disc-option = '':U.
    RETURN NO-APPLY.
  end.
  disc-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update-prop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update-prop d-dis-card
ON CHOOSE OF MENU-ITEM m_update-prop /* Изменение */
DO:
  assign
  prop-option = {&update}
  .
  RUN proc-b-prop IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    prop-option = '':U.
    RETURN NO-APPLY.
  end.
  prop-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-global
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-global d-dis-card
ON VALUE-CHANGED OF RS-global IN FRAME d-dis-card
DO:
  ASSIGN
  RS-GLOBAL.
  assign
  p-list-mode = Rs-GLobal.
  run Enable_ui in this-procedure .
  run OpenBr in this-procedure ( input yes, input no, input no).
  if ri <> ? then
  reposition br-discard to recid ri no-error.
  if available X_dis-card then
   log-res = br-discard:select-focused-row( ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-val
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-val d-dis-card
ON VALUE-CHANGED OF RS-val IN FRAME d-dis-card
DO:
 define variable v-doc-rec as recid no-undo .
  if available X_dis-card then do:
    v-doc-rec = recid(X_dis-card).
  end.
  Assign Rs-val.
  run OpenBr in this-procedure ( input yes, input no, input no).
  reposition br-discard to recid v-doc-rec no-error .
  APPLY "ENTRY" to br-discard.
  APPLY "VALUE-CHANGED" to br-discard.
  IF (p-list-mode = "client":u
  or p-list-mode = "card":U )
  and pravo then do:
      run get-totals in this-procedure No-ERROR.
      if error-status:error then do:
        message
        substitute("Нельзя подсчитать итоги по объектам фирм с разными базовыми валютами&1или не удалось определить валюты по одной из фирм!"
                   , {&new-line})
        view-as alert-box ERROR.
        RS-val = {&r-b-rubl}.
        DISPLAY RS-VAL
        WITH FRAME {&frame-name}.
        return no-apply.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SPattern
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SPattern d-dis-card
ON RETURN OF SPattern IN FRAME d-dis-card /* Поиск */
OR CTRL-J OF SPattern IN FRAME {&frame-name} DO:
 DEFINE VARIABLE v-next AS LOGICAL NO-UNDO.
 IF LAST-EVENT:LABEL = "CTRL-J" THEN DO:
   v-next = YES.
 END.
  assign RS-SEARCH SPattern.
  CASE rs-search:
    WHEN {&card} THEN DO:
       run proc-find-d-card in THIS-PROCEDURE ( INPUT v-next, input frame {&frame-name} spattern) no-error.
    END.
    WHEN {&client-cmp} THEN DO:
      run proc-find-client in THIS-PROCEDURE ( INPUT v-next, input frame {&frame-name} spattern) no-error.
    END.
    WHEN {&NAME} THEN DO:
       run proc-find-name in THIS-PROCEDURE ( INPUT v-next, input frame {&frame-name} spattern) no-error.
    END.
  END CASE.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-dis-card


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/srt-clmd.i
&browse-name = "br-DISCARD"
&frame-name  = {&frame-name}
&table-name = "X_DIS-CARD"
&ext-col = 26
&start-column  = 3
&label-clmn_1  = "{&label-clmn_1}"
&sort-clmn_1   = "{&sort-clmn_1}"
&dyn_sort-clmn_1   = "{&dyn_sort-clmn_1}"
&label-clmn_2  = "{&label-clmn_2}"
&sort-clmn_2   = "{&sort-clmn_2}"
&label-clmn_3  = "{&label-clmn_3}"
&sort-clmn_3   = "{&sort-clmn_3}"
&label-clmn_4  = "{&label-clmn_4}"
&sort-clmn_4   = "{&sort-clmn_4}"
&label-clmn_5  = "{&label-clmn_5}"
&sort-clmn_5   = "{&sort-clmn_5}"
&label-clmn_6  = "{&label-clmn_6}"
&sort-clmn_6   = "{&sort-clmn_6}"
&dyn_sort-clmn_6   = "{&dyn_sort-clmn_6}"
&label-clmn_7  = "{&label-clmn_7}"
&sort-clmn_7   = "{&sort-clmn_7}"
&label-clmn_8  = "{&label-clmn_8}"
&sort-clmn_8   = "{&sort-clmn_8}"
&label-clmn_9  = "{&label-clmn_9}"
&sort-clmn_9   = "{&sort-clmn_9}"
&label-clmn_10  = "{&label-clmn_10}"
&sort-clmn_10   = "{&sort-clmn_10}"
&label-clmn_11  = "{&label-clmn_11}"
&sort-clmn_11   = "{&sort-clmn_11}"
&label-clmn_13  = "{&label-clmn_13}"
&sort-clmn_13   = "{&sort-clmn_13}"
&label-clmn_14  = "{&label-clmn_14}"
&sort-clmn_14   = "{&sort-clmn_14}"
&label-clmn_15  = "{&label-clmn_15}"
&sort-clmn_15   = "{&sort-clmn_15}"
&label-clmn_16  = "{&label-clmn_16}"
&sort-clmn_16   = "{&sort-clmn_16}"
&label-clmn_17  = "{&label-clmn_17}"
&sort-clmn_17   = "{&sort-clmn_17}"
&label-clmn_18  = "{&label-clmn_18}"
&sort-clmn_18   = "{&sort-clmn_18}"
&dyn_sort-clmn_18   = "{&dyn_sort-clmn_18}"
&label-clmn_19  = "{&label-clmn_19}"
&sort-clmn_19   = "{&sort-clmn_19}"
&dyn_sort-clmn_19   = "{&dyn_sort-clmn_19}"
&label-clmn_20  = "{&label-clmn_20}"
&sort-clmn_20   = "{&sort-clmn_20}"
&dyn_sort-clmn_20   = "{&dyn_sort-clmn_20}"
&label-clmn_21  = "{&label-clmn_21}"
&sort-clmn_21   = "{&sort-clmn_21}"
&dyn_sort-clmn_21   = "{&dyn_sort-clmn_21}"
&label-clmn_22  = "{&label-clmn_22}"
&sort-clmn_22   = "{&sort-clmn_22}"
&dyn_sort-clmn_22   = "{&dyn_sort-clmn_22}"
&label-clmn_23  = "{&label-clmn_23}"
&sort-clmn_23   = "{&sort-clmn_23}"
&dyn_sort-clmn_23   = "{&dyn_sort-clmn_23}"
&label-clmn_24  = "{&label-clmn_24}"
&sort-clmn_24   = "{&sort-clmn_24}"
&label-clmn_25  = "{&label-clmn_25}"
&sort-clmn_25   = "{&sort-clmn_25}"
&label-clmn_26  = "{&label-clmn_26}"
&sort-clmn_26   = "{&sort-clmn_26}"

&open-query = "run OpenBr in this-procedure ( input yes, input no, input no)."
&open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input no)."
&re-move-clmn = "no"
&mv-brw-default = "no"
&sort-column-name     = "sort-column-name"
}


{ gbl/app_help.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
{ gbl/hot-key.i b-exit }
{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-history }

{ gbl/setfltnm.i }

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/brwrefre.i
  " if available X_dis-card then ri = recid(X_dis-card). ~
    RUn OpenBr in this-procedure ( input yes, input no, input no). ~
    reposition br-discard to recid ri no-error. "
}



ASSIGN b-add:MENU-MOUSE = 1.
/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

ON ENDKEY, END-ERROR OF FRAME d-dis-card OR  CHOOSE of b-exit /* Дисконтные карты */
DO:
  run gbl/markqwa.p (
                  input b-mark:sensitive
                , input rid-list) no-error.
    if error-status:error then return no-apply.
assign
v-uf-list_ =  (if available X_dis-card then string(recid(X_dis-card)) else {&question-mark}) + {&delim-par} +
              string({&sort-clmn_2}:width in browse br-discard ) + {&delim-par} +
              string(v-cli-name:WIDTH in browse br-discard) + {&delim-par} +
              string(v-cli-type-code:width in browse br-discard) + {&delim-par} +
              string({&sort-clmn_9}:width in browse br-discard )
.
  run uf-set in this-procedure (
      input  ({&uf-discards-p} + {&delim-par} + p-list-mode)
      ,input  v-cntxt-userid
      ,input v-uf-List_
      ,input v-uf-Naim
      ,input v-uf-print-graft
      ,input v-uf-sort-gr
      ,input v-uf-type-price
      ,input v-uf-type-val
  )  no-error .

END.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/conf-rd.i
  "'is-dc'"
  0
  "''":U
  0
  "''":U
  "''":U
  "''":U
  NO
  v-is-dc
  v-conf-type
  NO-ERROR
  }
  IF ERROR-STATUS:ERROR OR
    v-conf-type <> {&type-log} THEN
    v-is-dc = "no".
  if logical(v-is-dc) = no then do:
    message
    "В Вашей системе недоступна функциональность работы с дисконтными картами"
    view-as alert-box WARNING.
    undo main-block, return error .
  end.
  { gbl/conf-rd.i
  "'is-ef'"
  0
  "''":U
  0
  "''":U
  "''":U
  "''":U
  NO
  v-is-ef
  v-conf-type
  NO-ERROR
  }
  IF ERROR-STATUS:ERROR OR
    v-conf-type <> {&type-log} THEN
    v-is-ef = "no".

  { gbl/getcntxt.i get }
  { gbl/hostname.i p-curr-obj-type  p-curr-obj-code v-host-code v-host-name }

   glog = no.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_discount-cards-totals_print':U
    {&cntxt-firm}
    p-curr-host-code
    '':U
    0
    0
    0
    0
    false
    glog
  }

    if NOT glog then pravo = no.
    else pravo = yes.


    ASSIGN b-del:MENU-MOUSE = 1.
    RS-GLOBAL:radio-buttons =  {&first-main-card-label} + {&comma-char} + {&card} + {&comma-char} +
                               {&client-label} + {&comma-char} + {&client-cards} + {&comma-char} +
                               {&host-label} + {&comma-char} + {&company} + {&comma-char} +
                               {&global-label} + {&comma-char} + {&all}.
    RS-SEARCH:radio-buttons =   "Номер" + {&comma-char} + {&card} + {&comma-char} +
                                "Код" + {&comma-char} + {&client-cmp} + {&comma-char} +
                                "Назв./ФИО" + {&comma-char} + {&name}.
    assign
    rs-val:radio-buttons =  "{&abbr_rubli_firstshift}" + {&comma-char} + {&r-b-rubl} + {&comma-char} +
                            "Баз.вал." + {&comma-char} + {&r-b-base}.

    run enable_UI in this-procedure .
    run OpenBr in this-procedure ( input yes, input no, input no).
    if ri <> ? then
    reposition br-discard to recid ri no-error.
    if available X_dis-card then
    log-res = br-discard:select-focused-row( ).
    IF (p-list-mode = "client":u
    or p-list-mode = "card":U) and pravo then do:
      run get-totals in this-procedure .
    end.
    HIDE mark-num in frame {&frame-name} .
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-dis-card  _DEFAULT-DISABLE
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
  HIDE FRAME d-dis-card.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-dis-card
PROCEDURE enable_UI :
/*НЕЛЬЗЯ менять init для следующих переменных!!!!*/
define variable v-d-card-width as integer no-undo init 19.
define variable v-cli-name-width as integer no-undo init 29.
define variable v-cli-type-code-width as integer no-undo init 10.
define variable v-sourced-card-width as integer no-undo init 19.


run uf-get in this-procedure (
    input  ({&uf-discards-p} + {&delim-par} + p-list-mode)
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
if not error-status:error
and num-entries(v-uf-List_, {&delim-par}) = 5 then do:
    assign
    ri = (if entry(1, v-uf-list_, {&delim-par}) = {&question-mark}
         then ?
         else integer(entry(1, v-uf-list_, {&delim-par})))
    v-d-card-width = integer(entry(2, v-uf-list_, {&delim-par} ))
    v-cli-name-width = integer(entry(3, v-uf-list_, {&delim-par} ))
    v-cli-type-code-width = integer(entry(4, v-uf-list_, {&delim-par} ))
    v-sourced-card-width = integer(entry(5, v-uf-list_, {&delim-par} ))
    .
end.
if v-initial-height = 0 then do:
  v-initial-height = br-discard:height in frame {&frame-name} .
end.
ASSIGN
{&sort-clmn_5}:READ-ONLY IN BROWSE BR-DISCARD = YES
b-history:MENU-MOUSE in frame {&frame-name} = 1
b-chk:menu-mouse in frame {&frame-name} = 1
menu-item m_ef-cd-trans:sensitive in menu menu-b-chk = logical(v-is-ef)
b-CHG:POPUP-MENU IN FRAME d-dis-card = ?
b-add:MENU-MOUSE in frame {&frame-name} = 1
b-lkp:MENU-MOUSE in frame {&frame-name} =1
b-prop:MENU-MOUSE in frame {&frame-name} = 1
b-disc:MENU-MOUSE in frame {&frame-name} = 1
X_dis-card.d-card:resizable in browse br-discard = true
X_dis-card.d-card:width in browse br-discard = v-d-card-width
v-cli-name:resizable in browse br-discard = true
v-cli-name:width in browse br-discard = v-cli-name-width
v-cli-type-code:resizable in browse br-discard = true
v-cli-type-code:width in browse br-discard = v-cli-type-code-width
X_dis-card.sourced-card:resizable in browse br-discard = true
X_dis-card.sourced-card:width in browse br-discard = v-sourced-card-width
MENU-ITEM m_first-main-card:SENSITIVE IN MENU menu-b-lkp = (p-list-mode <> 'card':U)
br-discard:height = v-initial-height + ( if p-list-mode = "client" or p-list-mode = "card"
                                          then 0.0
                                          else 3.0)
MENU-ITEM m_cli-sourced:sensitive in menu menu-b-add = yes
MENU-ITEM m_sourced:sensitive in menu menu-b-add-copy = yes
.


if cli-recid <> ? then
FIND b_clients WHERE recid( b_clients ) = cli-recid NO-LOCK .
ENABLE
br-discard
b-exit
b-mark  WHEN can-do( bttns, "b-mark" )
b-sel  WHEN can-do( bttns, "b-sel" )
b-payment when v-cntxt-db-num = 0
b-sch
b-print
b-history
b-help
b-chk WHEN p-curr-obj-type = {&shop}
b-lkp
b-add WHEN (not transaction and v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0) /*and cli-recid = ?*/
b-del WHEN (not transaction and v-cntxt-db-num = 0 /* and lookup("b-add", bttns) > 0 */) /*and cli-recid = ?*/
b-chg WHEN (not transaction and v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0) /*and cli-recid = ?*/
b-prop
b-disc
b_clientsi WHEN cli-recid = ?
b-view
b-type
b-disc
RS-SEARCH
SPattern
RS-Global
b-sl
WITH FRAME d-dis-card.
if transaction then do:
  menu-item m_update-prop:sensitive in menu menu-b-prop  = no.
  menu-item m_update-disc:sensitive in menu menu-b-disc  = no.
end.
case p-list-mode:
  when {&all} then do:
    /*определим есть ли в системе фирмы с разной б.в.*/
    assign
    glob-val = one-base-cur-for-objs(output v-glob-curr-code)
    .
    ASSIGN
    b-add:POPUP-MENU IN FRAME d-dis-card = MENU MENU-b-add-copy:HANDLE.
    RS-GLOBAL = {&all}.
    glog = RS-GLOBAL:disable({&client-label}).
    glog = RS-GLOBAL:disable({&first-main-card-label}).
  end.
  when {&company} then do:
    ASSIGN
    b-add:POPUP-MENU IN FRAME d-dis-card = MENU MENU-b-add-copy:HANDLE.
    RS-GLOBAL = {&company}.
    glog = RS-GLOBAL:disable({&client-label}).
    glog = RS-GLOBAL:disable({&first-main-card-label}).
    glob-val = yes.
    { gbl/curr-r-b.i
      RS-val
    }
    display
    rs-val
    with frame {&frame-name}.
  end.
  when "client" then do:
    RS-GLOBAL = {&client-cards}.
    glog = RS-GLOBAL:disable({&global-label}).
    glog = RS-GLOBAL:disable({&host-label}).
    glog = RS-GLOBAL:disable({&first-main-card-label}).
    /*пока разрешим переключать валюту - а на самом деле можно или нет потом определим на ходу*/
    glob-val = yes.
  end.
  when "card" then do:
    t-totals = substitute("Итоги по всем картам к первич. осн. карте &1", p-first-main-card).
    RS-GLOBAL = {&card}.
    glog = RS-GLOBAL:disable({&global-label}).
    glog = RS-GLOBAL:disable({&host-label}).
    glog = RS-GLOBAL:disable({&client-label}).
    /*пока разрешим переключать валюту - а на самом деле можно или нет потом определим на ходу*/
    glob-val = yes.
  end.
end case.
display
RS-GLOBAL
WITH frame {&frame-name}.
IF glob-val AND pravo then
ENABLE RS-VAL when glob-val
WITH FRAME {&frame-name}.
else do:
  rs-val = {&r-b-rubl}.
  display
  rs-val
  with frame {&frame-name}.
  disable
  Rs-val
  WITH FRAME {&frame-name}.
end.
if NOT ((p-list-mode = "client":u
        or
        p-list-mode = "card":u )
and pravo) then
HIDE
F-disc-sum
F-gds-sum
F-netto-sum
F-pay-sum
F-num-chk
F-credit-sum
F-saldo-sum
t-totals
b-disc
IN FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Get-Totals d-dis-card
PROCEDURE Get-Totals :
DEFINE variable dopi2 as integer no-undo init -1.
define variable dop-num-chk as integer no-undo.
define variable dop-gds-sum as decimal no-undo.
define variable dop-disc-sum as decimal no-undo.
define variable dop-netto-sum as decimal no-undo.
define variable dop-pay-sum as decimal no-undo.
define variable dop-credit-sum as decimal no-undo.
define variable dop-saldo-sum as decimal no-undo.

CASE p-list-mode:
  when "client":U then do:
    IF RS-val = {&r-b-rubl} then do:
      FOR EACH b-d-c No-LOCK WHERE
              b-d-c.cli-type = b_clients.obj-type
          AND b-d-c.cli-code = b_clients.obj-code,
          EACH ub.dis-host NO-LOCK WHERE
              ub.dis-host.d-card = b-d-c.d-card
          AND ub.dis-host.host-code > 0
          and ub.dis-host.dt-code = 0
          :
        assign
        dop-num-chk = dop-num-chk + ub.dis-host.num-chk
        dop-gds-sum = dop-gds-sum + ub.dis-host.gds-tot-rubl
        dop-disc-sum = dop-disc-sum + ub.dis-host.gds-dis-rubl
        dop-netto-sum = dop-gds-sum - dop-disc-sum
        dop-pay-sum = dop-pay-sum + ub.dis-host.pay-tot-rubl
        dop-credit-sum = dop-netto-sum - dop-pay-sum
        dop-saldo-sum = dop-saldo-sum + b-d-c.saldo-rubl
        .
      END.
    end. /*RS-val = "rubl"*/
    if RS-VAL = {&r-b-base} then do:
        FOR EACH b-d-c No-LOCK WHERE
                b-d-c.cli-type = b_clients.obj-type
            AND b-d-c.cli-code = b_clients.obj-code,
            EACH dis-host NO-LOCK WHERE
                dis-host.d-card = b-d-c.d-card
            AND dis-host.host-code > 0
            and dis-host.dt-code = 0
            :
        /*убедимся что среди карт клиента нет карт по фирмам с разной баз вал*/
        if dopi2 = -1 then do:
            dopi2 = ub.dis-host.host-code.
            FINd FIRST ub.sysconf No-LOCK WHERE ub.sysconf.host-code = ub.dis-host.host-code no-error .
            if not available sysconf then do:
               undo, return error .
            end.
            dopi = sysconf.base-code.
        end.
        else if dopi2 <> ub.dis-host.host-code then do:
            FIND FIRST ub.sysconf No-LOCK WHERE ub.sysconf.host-code = ub.dis-host.host-code no-error .
            if not available ub.sysconf then do:
               undo, return error .
            end.
            if ub.sysconf.base-code <> dopi then do:
                return error.
            end.
        end.
        assign
        dop-num-chk = dop-num-chk + dis-host.num-chk
        dop-gds-sum = dop-gds-sum + dis-host.gds-tot-base
        dop-disc-sum = dop-disc-sum + dis-host.gds-dis-base
        dop-netto-sum = dop-gds-sum - dop-disc-sum
        dop-pay-sum = dop-pay-sum + dis-host.pay-tot-base
        dop-credit-sum = dop-netto-sum - dop-pay-sum
        dop-saldo-sum = dop-saldo-sum + b-d-c.saldo-base
        .
      END. /*FOR EACH b-d-c No-LOCK WHERE */
    end. /*    if RS-VAL = {&r-b-base} then do:*/
  end.
  when "card":U then do:
    IF RS-val = {&r-b-rubl} then do:
      FOR EACH b-d-c No-LOCK WHERE
              b-d-c.first-main-card = p-first-main-card,
          EACH dis-host NO-LOCK WHERE
              dis-host.d-card = b-d-c.d-card
          AND dis-host.host-code > 0
          and dis-host.dt-code = 0:
        assign
        dop-num-chk = dop-num-chk + dis-host.num-chk
        dop-gds-sum = dop-gds-sum + dis-host.gds-tot-rubl
        dop-disc-sum = dop-disc-sum + dis-host.gds-dis-rubl
        dop-netto-sum = dop-gds-sum - dop-disc-sum
        dop-pay-sum = dop-pay-sum + dis-host.pay-tot-rubl
        dop-credit-sum = dop-netto-sum - dop-pay-sum
        dop-saldo-sum = dop-saldo-sum + b-d-c.saldo-rubl
        .
      END.
    end. /*RS-val = "rubl"*/
    if RS-VAL = {&r-b-base} then do:
        FOR EACH b-d-c No-LOCK WHERE
                b-d-c.first-main-card = p-first-main-card,
            EACH dis-host NO-LOCK WHERE
                dis-host.d-card = b-d-c.d-card
            AND dis-host.host-code > 0
            and dis-host.dt-code = 0 :
        /*убедимся что среди карт клиента нет карт по фирмам с разной баз вал*/
        if dopi2 = -1 then do:
            dopi2 = dis-host.host-code.
            FINd FIRST sysconf No-LOCK WHERE sysconf.host-code = dis-host.host-code.
            dopi = sysconf.base-code.
        end.
        else if dopi2 <> dis-host.host-code then do:
            FIND FIRST sysconf No-LOCK WHERE sysconf.host-code = dis-host.host-code.
            if sysconf.base-code <> dopi then do:
                return error.
            end.
        end.
        assign
        dop-num-chk = dop-num-chk + dis-host.num-chk
        dop-gds-sum = dop-gds-sum + dis-host.gds-tot-base
        dop-disc-sum = dop-disc-sum + dis-host.gds-dis-base
        dop-netto-sum = dop-gds-sum - dop-disc-sum
        dop-pay-sum = dop-pay-sum + dis-host.pay-tot-base
        dop-credit-sum = dop-netto-sum - dop-pay-sum
        dop-saldo-sum = dop-saldo-sum + b-d-c.saldo-base
        .
      END. /*FOR EACH b-d-c No-LOCK WHERE */
    end. /*    if RS-VAL = {&r-b-base} then do:*/
  end.
END CASE.
assign
f-num-chk = dop-num-chk
f-gds-sum = dop-gds-sum
f-disc-sum = dop-disc-sum
f-netto-sum = dop-netto-sum
F-pay-sum = dop-pay-sum
f-credit-sum = dop-credit-sum
f-saldo-sum = dop-saldo-sum
.
DISPLAY
t-totals
f-disc-sum
f-gds-sum
f-netto-sum
F-pay-sum
f-num-chk
f-credit-sum
f-saldo-sum
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr d-dis-card
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ( input "Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-debug-file

&scop flt-open-open-query OPEN QUERY br-discard FOR EACH X_dis-card

&scop flt-open-dyn_open-query FOR EACH X_dis-card

&scop flt-open-query-handle QUERY br-discard:handle

&scop flt-open-query p-open-query

&scop flt-open-find-next p-find-next

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-buffer-name  X_dis-card

&scop flt-open-open-query-tail , FIRST X_clients NO-LOCK WHERE ~
X_clients.obj-type = X_dis-card.cli-type ~
AND X_clients.obj-code = X_dis-card.cli-code ~
, FIRST X_dis-host NO-LOCK WHERE ~
         X_dis-host.host-code = 0     ~
     AND X_dis-host.d-card = X_dis-card.d-card                   ~
     and X_dis-host.dt-code = 0  ~

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-waitfram yes

&scop flt-open-table-name X_dis-card

&scop flt-open-search-option no-lock

CASE p-list-mode:
    when {&company} then do:
      if p-open-query then do:
        ASSIGN
        frame {&frame-name}:TITLE = substitute("ДИСКОНТНЫЕ КАРТЫ ПО ФИРМЕ &1", v-host-name).
      end.
      assign
      filter-point-name = filter-point-name0 + " " + p-list-mode
      filter-point = filter-point0 + " " + p-list-mode.
      if rs-search = {&name} then do:
        &scop flt-open-find-buffer-name  X_clients
        if sort-column-name = '':u then do:
          { gbl/fltopend.i
            &where-cond = " X_dis-card.emitent-host-code = p-curr-host-code "
            &dyn_where-cond = " substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code) "
            &use-ind = "  "
            &by = " by X_dis-card.d-card "
          }

        end.
        else do:
          { gbl/fltopend.i
            &where-cond = " X_dis-card.emitent-host-code = p-curr-host-code "
            &dyn_where-cond = " substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code) "
            &use-ind = "  "
            &by = "  "
          }
        end.

      end.
      else do:
        &scop flt-open-find-buffer-name  X_dis-card
      if sort-column-name = '':u then do:
        { gbl/fltopend.i
          &where-cond = " X_dis-card.emitent-host-code = p-curr-host-code "
          &dyn_where-cond = " substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code) "
          &use-ind = "  "
          &by = " by X_dis-card.d-card "
        }

      end.
      else do:
        { gbl/fltopend.i
          &where-cond = " X_dis-card.emitent-host-code = p-curr-host-code "
          &dyn_where-cond = " substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code) "
          &use-ind = "  "
          &by = "  "
        }
      end.
    end.
    end. /*when {&company} then do:*/
    when {&all} then do:
      if p-open-query then do:
        ASSIGN
        frame {&frame-name}:TITLE = "ГЛОБАЛЬНЫЕ ДИСКОНТНЫЕ КАРТЫ ".
      end.
      assign
      filter-point-name = filter-point-name0 + " " + p-list-mode
      filter-point = filter-point0 + " " + p-list-mode.
      if rs-search = {&name} then do:
        &scop flt-open-find-buffer-name  X_clients
      if sort-column-name = '':u then do:
        { gbl/fltopend.i
          &where-cond = " X_dis-card.emitent-host-code = 0 "
          &use-ind = "  "
          &by = " by X_dis-card.d-card  "
        }
       end.
       else do:
        { gbl/fltopend.i
          &where-cond = " X_dis-card.emitent-host-code = 0 "
          &use-ind = "  "
          &by = " "
        }
       end.
    end.
      else do:
        &scop flt-open-find-buffer-name  X_dis-card
        if sort-column-name = '':u then do:
          { gbl/fltopend.i
            &where-cond = " X_dis-card.emitent-host-code = 0 "
            &use-ind = "  "
            &by = " by X_dis-card.d-card  "
          }
        end.
        else do:
          { gbl/fltopend.i
            &where-cond = " X_dis-card.emitent-host-code = 0 "
            &use-ind = "  "
            &by = " "
          }
        end.
       end.
    end.
    when "client":u then do:
      if p-open-query then do:
        ASSIGN
        frame {&frame-name}:TITLE = substitute("ДИСКОНТНЫЕ КАРТЫ ПО КЛИЕНТУ &1", b_clients.obj-name)
        .
      end.
      assign
      filter-point-name = filter-point-name0 + " " + p-list-mode
      filter-point = filter-point0 + " " + p-list-mode.
      &scop flt-open-find-buffer-name  X_dis-card
        { gbl/fltopend.i
          &where-cond = " X_dis-card.cli-type = b_clients.obj-type AND X_dis-card.cli-code = b_clients.obj-code "
          &dyn_where-cond = " substitute('X_dis-card.cli-type = &1&2&1 AND X_dis-card.cli-code = &3 ', ~{&double-quote~}, b_clients.obj-type, b_clients.obj-code)"
          &use-ind = "  "
          &by = " by X_dis-card.d-card   "
        }
    end.
    when "card":u then do:
      if p-open-query then do:
        ASSIGN
        frame {&frame-name}:TITLE = substitute("ДИСКОНТНЫЕ КАРТЫ ПО перв.осн. КАРТЕ &1" , p-first-main-card)
        .
      end.
      assign
      filter-point-name = filter-point-name0 + " " + p-list-mode
      filter-point = filter-point0 + " " + p-list-mode.
      &scop flt-open-find-buffer-name  X_dis-card
        { gbl/fltopend.i
          &where-cond = " X_dis-card.first-main-card = p-first-main-card "
          &dyn_where-cond = " substitute('X_dis-card.first-main-card = &1&2&1', ~{&double-quote~}, p-first-main-card )"
          &use-ind = "  "
          &by = " by X_dis-card.d-card   "
        }
    end.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-discard to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-discard:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-discard in frame {&frame-name}.
APPLY "ENTRY" TO br-discard.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-disc d-dis-card
PROCEDURE proc-b-disc :
DEFINE variable v-is-error AS LOGICAL NO-UNDO.
DEFINE variable v-update-dccr AS LOGICAL NO-UNDO.
define variable loc#log as logical no-undo .
IF NOT AVAILABLE X_dis-card THEN DO:
   disc-option = '':U.
   RETURN NO-APPLY.
END.
IF disc-option = {&UPDATE} THEN DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_referense-dis_input-deletion-updating':U
    {&cntxt-firm}
    p-curr-host-code
    '':U
    0
    0
    0
    0
    false
    loc#log
  }
END.
run ref/ddcrattr.p (
               input parparentproc
              ,input disc-option
              ,input X_dis-card.d-card
              ,input p-curr-host-code
              ,input p-curr-obj-type
              ,input p-curr-obj-code
              ,input yes /*update on exit*/
              ,output v-update-dccr
              ,output v-is-error
              ) no-error .
if error-status :error
or v-is-error
then do:
  message
  "Ошибка при вызове списка скидок ДК" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box .
  disc-option = '':U.
  undo, return error.
end. /*doe*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-history d-dis-card
PROCEDURE proc-b-history :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER loc-option as character no-undo.
define variable parref-list as character no-undo .

if not  available X_dis-card THEN return error.
CASE loc-option:
  when "c-dc-hist":U then do:
    run ref/cdchist.w (
                    INPUT parparentproc
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input "":U
                    ,input "one":U
                    ,input X_dis-card.d-card
                    ,input X_dis-card.card-num
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input p-curr-host-code
                    ,input ? /*p-corr-user-db-num */
                    ,input "":U /*p-corr-user-name */
                    ,input "":U /*p-subject*/
                    ,input ? /*p-db-num */
                    /*записи в выборке*/
                    ,input-output parref-list
                 ) no-error .
  end.
  when "c-dc-hist-plus":U then do:
    run ref/cdchist.w (
                    INPUT parparentproc
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input "":U
                    ,input "card-num":U
                    ,input X_dis-card.d-card
                    ,input X_dis-card.card-num
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input p-curr-host-code
                    ,input ?
                    ,input "":U /*p-corr-user-name */
                    ,input "":U /*p-subject*/
                    ,input ? /*p-db-num */
                    /*записи в выборке*/
                   ,input-output parref-list
                 ) no-error .
  end.
END CASE.
apply "entry" to br-discard in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-prop d-dis-card
PROCEDURE proc-b-prop :
define variable loc#log as logical no-undo.
define variable v-update-attr as logical no-undo .
define variable v-is-error as logical no-undo .
define variable log-res as logical no-undo .
define buffer prop_dis-card for ub.dis-card.
define buffer buf_dis-card-property for ub.dis-card-property.
if not available X_dis-card then return error .
FIND FIRST prop_dis-card No-LOCK WHERE
             recid(prop_dis-card) = recid(X_dis-card) no-error.
if not available prop_dis-card then return error .
IF prop-option = {&UPDATE} THEN DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_referense-dis_input-deletion-updating':U
    {&cntxt-firm}
    p-curr-host-code
    '':U
    0
    0
    0
    0
    false
    loc#log
  }
END.
do
on error undo, return error
:
  run ref/dc-propr.p ( input parparentproc
                 ,input (if prop_dis-card.status_ <> {&deleted-status}
                         and loc#log
                         AND prop-option = {&update}
                         then {&update} else {&lookup})
                 ,input prop_dis-card.d-card
                 ,input prop_dis-card.emitent-host-code
                 ,input prop_dis-card.type
                 ,input p-curr-host-code
                 ,input p-curr-obj-type
                 ,input p-curr-obj-code
                 ,input yes /*update on exit*/
                 ,output v-update-attr
                 ,output v-is-error
                ) no-error .
  if error-status:error then undo, return error .
  if prop-option = {&update} then do: /* ri = recid( X_dis-card ) */
    ri = recid(X_dis-card).
    run OpenBr in this-procedure ( input yes, input no, input no).
    reposition br-discard to recid ri no-error.
    if error-status:error then do:
&scop rec-recid ri
      {&cant-positioning}.
    end.
    if available X_dis-card then do:
      log-res = br-discard:select-focused-row( ) in frame {&frame-name} .
    end.
  end.
end. /*doe*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch d-dis-card
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-ri as recid no-undo.
assign
v-ri = (if avail X_dis-card then recid(X_dis-card) else ?)
.
assign
tbl = 'dis-card'
join-tbl = 'X_dis-card'
fld = ""
lab = ""
spr = ""
dim = '0'
.

run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code', 'Клиент(один)', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type', 'Тип клиента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-code', 'Код клиента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-card', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-pcnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('category', 'Категория', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('emitent-host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('issue-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('issue-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('valid-date', 'Действ.до', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('type', 'Тип карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('credit-card', 'Кредитная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sourced-card', 'К карте', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('saldo-rubl', 'Сальдо {&abbr_rubli}', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('saldo-base', 'Сальдо баз_вал', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('main-card', 'Основная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-subsid', 'Дополнительная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('first-card', 'Первичная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('first-main-card', 'Первичная основная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sourced-card', 'Перевыпущена к', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('overissue-num', 'Порядок в цепочке перевыпуска', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

DO on stop undo, leave:
    run gbl/filter.w (  input parparentproc
                  , input (filter-point + {&delim-par} +
                    filter-point-name + {&delim-par} +
                    string(yes))
                  , input tbl
                  , input join-tbl
                  , input fld
                  , input lab
                  , input spr
                  , input dim).
    run OpenBr in this-procedure ( input yes, input no, input no).
    if v-ri <> ? then do:
      reposition br-discard to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-discard in frame {&frame-name} .
END .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-client d-dis-card
PROCEDURE proc-find-client :
define input parameter p-next as logical no-undo.
define input parameter p-cli-code like ub.dis-card.cli-code no-undo.
define variable v-cli-code as character no-undo.
define variable v-cli-code-int as integer no-undo .
assign
v-cli-code-int = integer(p-cli-code)
NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    message "Введите ЧИСЛЕННЫЙ код клиента!" view-as alert-box ERROR.
    RETURN ERROR.
END.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute("and (X_dis-card.cli-type = {&cmp} or X_dis-card.cli-type = {&prs}) and X_dis-card.cli-code = &1 "
      , v-cli-code-int)
    ).
apply "entry":u to spattern in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-d-card d-dis-card
PROCEDURE proc-find-d-card :
define input parameter p-next as logical no-undo.
define input parameter p-d-card like ub.dis-card.d-card no-undo.
assign
p-d-card = replace(p-d-card, {&double-quote}, "":U)
p-d-card = replace(p-d-card, {&single-quote}, {&single-quote} + {&single-quote})
p-d-card = {&double-quote} + p-d-card + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute(" and X_dis-card.d-card  begins &1 " , p-d-card)
    ).
apply "entry":u to spattern in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-name d-dis-card
PROCEDURE proc-find-name :
define input parameter p-next as logical no-undo.
define input parameter p-name AS CHARACTER no-undo.
DEFINE VARIABLE v-cli-type LIKE ub.dis-card.cli-type NO-UNDO.
DEFINE VARIABLE v-cli-code LIKE ub.dis-card.cli-code NO-UNDO.
assign
p-name = replace(p-name, {&double-quote}, "":U)
p-name = replace(p-name, {&single-quote}, {&single-quote} + {&single-quote})
p-name = {&double-quote} + p-name + {&double-quote}
    .

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input p-next  /* p-find-next  */
    ,input substitute(" and X_clients.obj-name begins &1 "
                      , p-name)).

apply "entry":u to spattern in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME