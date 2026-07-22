&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER X_clients FOR ub.clients.
DEFINE NEW SHARED BUFFER X_clients-attr FOR ub.clients-attr.
DEFINE NEW SHARED BUFFER X_firm FOR ub.firm.
DEFINE NEW SHARED BUFFER X_person FOR ub.person.
DEFINE NEW SHARED BUFFER X_shop FOR ub.shop.
DEFINE NEW SHARED BUFFER X_store FOR ub.store.
define new shared buffer X_contract-attr for ub.contract-attr .
define new shared buffer X_contractr for ub.contract .

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

Author: Черных В.Г., Романов И.И.

Created: 14/03/97

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-bttns     as   character no-undo. /* список включенных батонов */

/*параметры ранее хранившиеся в шареных переменных*/
define input parameter c-types     as character no-undo . /* м/б : все, орг, чел, скл, маг, про  init {&all}*/
define input parameter c-group    like ub.clients.grp-name no-undo . /* м/б : все, <имя группы>  init {&all} */
define input parameter c-status   as character no-undo . /* м/б : текущие, все, удаленные init {&current} */
define input parameter c-recid    as recid no-undo .  /* for reposition */

define input parameter c-added    as character no-undo . /*",,,,,,NO,,":u */
/* список (разделитель запятая) :
     используется для справочника клиентов (выбор клиентов определенного типа)
    должен содержать следущющие 7 элементов
      "yes"/"no"/"?"/"", - признак поставщиков товаров
      "yes"/"no"/"?"/"", - признак поставщиков на конс-цию
      "yes"/"no"/"?"/"", - признак поставщиков услуг
      "yes"/"no"/"?"/"", - признак покупателей товаров
      "yes"/"no"/"?"/"", - признак покупателей на конс-цию
      "yes"/"no"/"?"/"", - признак покупателей услуг
      "NO"/"ИЛИ"/"И" - объединяются ли и как эти признаки
    может содержать следующие 3 элемента
      "yes"/"no"/"?"/"", - признак наличия диск. карты покупател
      "yes"/"no"/"?"/"", - признак наличия индив. скидки
      "yes"/"no"/"?"/"" - признак ненулевого лимита кредита
    */

/*про запас* и для вызова из АРМ где нет объекта*/
define input parameter c-other    as character no-undo .
/*список [название параметра]=[значение параметра] с разделителем   ";":U */


/*если какой-то из вышеуказанных 6 входных параметров  = ? то значение берется из ubflt.usr-flt если не находится то- поумолчанию*/
define output parameter  p-rid-list    as  character no-undo . /* список recid'ов выбранных клиентов */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Список клиентов" .
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8':u,parparentproc,p-bttns,c-types,c-group,c-status,c-recid,c-added,c-other)" }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i  }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ cmp/operlist.i }
{ gbl/clntattr.i }
{ gbl/cur-time.i }
{ ref/cgrplbfn.i }
{ gbl/waitfram.i }
{ gbl/usr-flt.i  }
{ gbl/getcntxt.i def }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ ref/t-l-b.i  "NEW SHARED"  }
{ gbl/key-rec.i }
&SCOP local-code "Код"
&SCOP local-name "Название"
&SCOP local-inn "ИНН"


&scop display-browse       (mark-string(buffer X_clients, v-rid-list)) COLUMN-LABEL "*" FORMAT "x(1)" ~
      (STRING (X_clients.obj-code, "999999999")  +  " "  +  TRIM (X_clients.obj-type)) COLUMN-LABEL "Код/Тип" FORMAT "X(13)" ~
      var-cli-name COLUMN-LABEL "Контрагент" FORMAT "x(130)" ~
      X_clients.host-code COLUMN-LABEL "Фирма" FORMAT ">>>>>>>>9" ~
      X_clients.db-num COLUMN-LABEL "БД" FORMAT ">>>>>>>>9" ~
      X_clients.is-prod COLUMN-LABEL "Пр-ль" FORMAT "  +/" ~
      X_clients.sup-gds COLUMN-LABEL "Пост-к/т" FORMAT "  +/" ~
      X_clients.sup-cons COLUMN-LABEL "Пост-к/к" FORMAT "  +/"  ~
      X_clients.buy-gds COLUMN-LABEL "Пок-ль/т" FORMAT "  +/" ~
      X_clients.buy-cons COLUMN-LABEL "Пок-ль/к" FORMAT "  +/" ~
      X_clients.buy-serv COLUMN-LABEL "Пок-ль/у" FORMAT "  +/" ~
      X_clients.grp-name FORMAT "X(60)" ~
      cli-dcard COLUMN-LABEL "Дисконтная карта" FORMAT "x(11)" ~
      (cli-dpcnt) COLUMN-LABEL "% скидки" FORMAT "->>>9.99" ~
      X_clients.PS FORMAT "X(60)" ~
      X_clients.lim-kr ~
      price-grp COLUMN-LABEL "Группа ценообразования" FORMAT "x(20)"


&SCOPED-DEFINE FIRST-ATTR  , FIRST X_clients-attr NO-LOCK  WHERE  X_clients-attr.obj-type = X_clients.obj-type AND  ~
                                                                   X_clients-attr.obj-code = X_clients.obj-code AND  ~
                                                                   X_clients-attr.attr-code = attr-option_ AND ~
                                                                   X_clients-attr.attr-value = "yes":U

&SCOPED-DEFINE APPLY-ENTRY      case var-br-name : ~
        when "cli-list":U then do: ~
           apply "entry" to Cli-List in frame ~{&frame-name~}. ~
        end. ~
        when "cli-listA":U then do: ~
           apply "entry" to Cli-ListA in frame ~{&frame-name~}. ~
        end. ~
        when "cli-listB":U then do: ~
           apply "entry" to Cli-ListB in frame ~{&frame-name~}. ~
        end. ~
        end case.

&SCOPED-DEFINE run-openbr  case var-br-name : ~
        when "cli-list":U then do: ~
           Run OpenBR in this-procedure (yes, no, ' ':U, yes) no-error  . ~
        end. ~
        when "cli-listA":U then do: ~
           Run OpenBRA in this-procedure (yes, no, ' ':U, yes) no-error  . ~
        end. ~
        when "cli-listB":U then do: ~
           Run OpenBRB in this-procedure (yes, no, ' ':U, yes) no-error  . ~
        end. ~
        end case.

&SCOPED-DEFINE run-openbr-false case var-br-name : ~
        when "cli-list":U then do: ~
           Run OpenBR in this-procedure (yes, no, ' ':U, no) no-error  . ~
        end. ~
        when "cli-listA":U then do: ~
           Run OpenBRA in this-procedure (yes, no, ' ':U, no) no-error  . ~
        end. ~
        when "cli-listB":U then do: ~
           Run OpenBRB in this-procedure (yes, no, ' ':U, no) no-error  . ~
        end. ~
        end case.


&scoped-define reposition-to-ri   case var-br-name : ~
        when "cli-list":U then do: ~
           reposition Cli-List to recid ri no-error . ~
        end. ~
        when "cli-listA":U then do: ~
           reposition Cli-ListA to recid ri no-error . ~
        end. ~
        when "cli-listB":U then do: ~
           reposition Cli-ListB to recid ri no-error .  ~
        end. ~
        end case.

&scoped-define reposition-to-row-1  case var-br-name : ~
        when "cli-list":U then do: ~
           reposition Cli-List to row 1 no-error . ~
        end. ~
        when "cli-listA":U then do: ~
           reposition Cli-ListA to row 1 no-error . ~
        end. ~
        when "cli-listB":U then do: ~
           reposition Cli-ListB to row 1 no-error .  ~
        end. ~
        end case.

&global-define refresh-br  case var-br-name : ~
        when "cli-list":U then do: ~
           g#log = Cli-List:refresh() in frame {&frame-name} . ~
        end. ~
        when "cli-listA":U then do: ~
           g#log = Cli-ListA:refresh() . ~
        end. ~
        when "cli-listB":U then do: ~
           g#log = Cli-ListB:refresh() .  ~
        end. ~
        end case.


&scoped-define apply-value-changed  case var-br-name : ~
        when "cli-list":U then do: ~
           apply "value-changed" to Cli-List in frame {&frame-name} . ~
        end. ~
        when "cli-listA":U then do: ~
           apply "value-changed" to Cli-ListA in frame {&frame-name} . ~
        end. ~
        when "cli-listB":U then do: ~
            apply "value-changed" to Cli-ListB in frame {&frame-name} . ~
        end. ~
        end case.

&global-define SELECT-NEXT-ROW  case var-br-name : ~
        when "cli-list":U then do: ~
           g#log = Cli-List:select-next-row (). ~
        end. ~
        when "cli-listA":U then do: ~
           g#log = Cli-ListA:select-next-row (). ~
        end. ~
        when "cli-listB":U then do: ~
           g#log = Cli-ListB:select-next-row ().  ~
        end. ~
        end case.

&scoped-define SELECT-focused-ROW  case var-br-name : ~
        when "cli-list":U then do: ~
           g#log = Cli-List:select-focused-row (). ~
        end. ~
        when "cli-listA":U then do: ~
           g#log = Cli-ListA:select-focused-row (). ~
        end. ~
        when "cli-listB":U then do: ~
           g#log = Cli-ListB:select-focused-row ().  ~
        end. ~
        end case.

&scoped-define SELECT-ROW-1  case var-br-name : ~
        when "cli-list":U then do: ~
           g#log = Cli-List:select-row (1). ~
        end. ~
        when "cli-listA":U then do: ~
           g#log = Cli-ListA:select-row (1). ~
        end. ~
        when "cli-listB":U then do: ~
           g#log = Cli-ListB:select-row (1).  ~
        end. ~
        end case.

&scop cant-positioning ~
  find first pos_clients no-lock where ~
      recid( pos_clients ) = ~{&rr~} no-error . ~
  message ~
 substitute("Невозможно позиционироваться на клиенте &1&2Клиент был добавлен (или изменен или удален)&2и теперь не попадает в текущую выборку" ~
            ,(if available pos_clients then (pos_clients.obj-type + string(pos_clients.obj-code)) else '':U)  ~
            , ~{&new-line~}) view-as alert-box WARNING


define variable v-types     as character no-undo init {&all}. /* м/б : все, орг, чел, скл, маг, про  init {&all}*/
define variable v-group    like ub.clients.grp-name no-undo init {&all}. /* м/б : все, <имя группы>  init {&all} */
define variable v-status   as character no-undo init {&current}. /* м/б : текущие, все, удаленные init {&current} */
define variable v-recid    as recid no-undo init ?.  /* for reposition */
define variable v-added    as character no-undo init  ",,,,,,NO,,":u  .
define variable v-other    as character no-undo init "":U.
define variable v-without-obj as logical no-undo .
define variable v-s-deploy as logical no-undo .
define variable v-lock-cli-type as logical no-undo .
define variable v-is-news as logical no-undo .
define variable v-tank-farm-for as character no-undo.
define variable v-auto-tank-for as character no-undo.
define variable v-tank-farm-for-supp as character no-undo.
define variable v-auto-tank-for-supp as character no-undo.
define variable p-callback-handle as handle no-undo .
define variable v-new-selection-flag as logical no-undo .
define variable v-is-prod as logical no-undo.

define variable v-rid-list as character no-undo .
DEFINE VARIABLE cli-dpcnt as decimal no-undo .
DEFINE VARIABLE cli-dcard like ub.dis-card.d-card no-undo .
DEFINE VARIABLE template-recid as recid no-undo.
DEFINE VARIABLE All-Suppliers as logical   no-undo .
DEFINE VARIABLE SupGds as logical   no-undo .
DEFINE VARIABLE SupCons as logical   no-undo .
DEFINE VARIABLE SupServ as logical   no-undo .
DEFINE VARIABLE All-Buyers as logical    no-undo .
DEFINE VARIABLE BuyGds as logical   no-undo .
DEFINE VARIABLE BuyCons as logical  no-undo .
DEFINE VARIABLE BuyServ as logical   no-undo .
DEFINE VARIABLE WLim-kr AS LOGICAL NO-UNDO.
define variable f-turn-buyer as logical   no-undo .
define variable f-grp-buyer  as logical   no-undo .
DEFINE VARIABLE JoinType            as  char    init "NO" no-undo .
DEFINE VARIABLE show-as             as char no-undo .
DEFINE VARIABLE Curr-Grp-Name as char no-undo .
DEFINE VARIABLE attr-option_ as  character no-undo    init "".
DEFINE VARIABLE filter-point as character no-undo .
DEFINE VARIABLE filter-point0 as character no-undo .
DEFINE VARIABLE sort-column-name as character no-undo .
DEFINE VARIABLE photo   as logical no-undo .
DEFINE VARIABLE var-br-name as character no-undo.
DEFINE VARIABLE var-prev-br-name as character no-undo.
DEFINE VARIABLE getc-recid as logical no-undo .
define variable g#log as logical no-undo .
define variable attr-option as character no-undo .
define variable sert-option as character no-undo .
define variable price-grp as character no-undo .
/*выбор что добавлять*/
define variable choice   as      logical no-undo    init ?.
define variable var-cli-name as character no-undo.
define variable v-obj-name-width as decimal no-undo init 40.
define variable v-grp-name-width as decimal no-undo init 60.
define variable v-filter-name as character no-undo .

DEFINE VARIABLE is-edi  as logical no-undo .
DEFINE VARIABLE is-fin  as logical no-undo .
define variable is-price-buyer as logical   no-undo .
DEFINE VARIABLE par-type    as char no-undo .
define variable v-start as logical no-undo init yes.

define buffer s-clients for ub.clients.
define new shared buffer clients for ub.clients.
define new shared buffer clients-attr for ub.clients-attr.
define buffer pos_clients for ub.clients.

DEFINE VARIABLE v-list-b as logical no-undo INIT NO.
define new shared buffer x_temp-list-buyer for temp-list-buyer  .
define variable p-sum-1  as character no-undo .
define variable p-sum-2  as character no-undo .
define variable p-grp-b-name as character no-undo .
define variable p-grp-buyer-id     as integer   no-undo .
define variable p-grp-buyer-db-num as integer   no-undo .

define variable v-last-inn-rec as recid no-undo.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME CLi-List

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_clients X_clients-attr x_temp-list-buyer

/* Definitions for BROWSE CLi-List                                      */
&Scoped-define FIELDS-IN-QUERY-CLi-List {&display-browse}
&Scoped-define ENABLED-FIELDS-IN-QUERY-CLi-List
&Scoped-define SELF-NAME CLi-List
&Scoped-define QUERY-STRING-CLi-List FOR EACH X_clients NO-LOCK indexed-reposition
&Scoped-define OPEN-QUERY-CLi-List OPEN QUERY {&SELF-NAME} FOR EACH X_clients NO-LOCK indexed-reposition.
&Scoped-define TABLES-IN-QUERY-CLi-List X_clients
&Scoped-define FIRST-TABLE-IN-QUERY-CLi-List X_clients


/* Definitions for BROWSE CLi-ListA                                     */
&Scoped-define FIELDS-IN-QUERY-CLi-ListA {&display-browse}
&Scoped-define ENABLED-FIELDS-IN-QUERY-CLi-ListA
&Scoped-define SELF-NAME CLi-ListA
&Scoped-define QUERY-STRING-CLi-ListA FOR EACH X_clients NO-LOCK, ~
             EACH X_clients-attr OF x_clients NO-LOCK
&Scoped-define OPEN-QUERY-CLi-ListA OPEN QUERY {&SELF-NAME} FOR EACH X_clients NO-LOCK, ~
             EACH X_clients-attr OF x_clients NO-LOCK.
&Scoped-define TABLES-IN-QUERY-CLi-ListA X_clients X_clients-attr
&Scoped-define FIRST-TABLE-IN-QUERY-CLi-ListA X_clients
&Scoped-define SECOND-TABLE-IN-QUERY-CLi-ListA X_clients-attr


/* Definitions for BROWSE CLi-ListB                                     */
&Scoped-define FIELDS-IN-QUERY-CLi-ListB {&display-browse}
&Scoped-define ENABLED-FIELDS-IN-QUERY-CLi-ListB
&Scoped-define SELF-NAME CLi-ListB
&Scoped-define QUERY-STRING-CLi-ListB FOR EACH X_clients NO-LOCK, ~
             first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR             (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))
&Scoped-define OPEN-QUERY-CLi-ListB OPEN QUERY {&SELF-NAME} FOR EACH X_clients NO-LOCK, ~
             first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR             (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code)).
&Scoped-define TABLES-IN-QUERY-CLi-ListB X_clients x_temp-list-buyer
&Scoped-define FIRST-TABLE-IN-QUERY-CLi-ListB X_clients
&Scoped-define SECOND-TABLE-IN-QUERY-CLi-ListB x_temp-list-buyer


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-bank B-docs ~
Goods-by-prod b-dc b-zak b-sert B-attr b-hist b-print B-sch B-Help ~
RECT-status RECT-types RECT-All-or-Group B-add B-add-prs B-lkp b-chg ~
b-del B-price-type B-cont B-grp B-edi B-photo Find-by NameOrCode CLi-ListB ~
CLi-ListA CLi-List All-Or-Group Del-Filters Cli-Types Cli-Status mark-num
&Scoped-Define DISPLAYED-OBJECTS Find-by NameOrCode All-Or-Group Cli-Types ~
Cli-Status mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-client Dialog-Frame
FUNCTION get-client RETURNS CHARACTER
  (buffer loc_clients for clients  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( buffer loc_clients for clients, input mark-list as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD prep-nameorcode Dialog-Frame
FUNCTION prep-nameorcode RETURNS CHARACTER
  ( input p-nameorcode as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU m-gds
       MENU-ITEM m-gds-1        LABEL "Товары по производителю"
       MENU-ITEM m-gds-2        LABEL "Остатки по поставщику (партии)"
       MENU-ITEM m-gds-3        LABEL "Остатки по поставщику (товары)"
       MENU-ITEM m-gds-4        LABEL "Обороты по поставщику (партии)"
       MENU-ITEM m-gds-5        LABEL "Обороты по поставщику (товары)"
       MENU-ITEM m-gds-6        LABEL "Обороты по контрагенту"
       RULE
       MENU-ITEM m_turnover-buyer LABEL "Обороты по покупателю".

DEFINE MENU MENU-B-attr
       MENU-ITEM m_lookup-attr  LABEL "Просмотр"
       MENU-ITEM m_update-attr  LABEL "Изменение"     .

DEFINE MENU MENU-B-sert
       MENU-ITEM m_sert         LABEL "Сертификаты"
       MENU-ITEM m_licsupp      LABEL "Лицензии на поставку алкоголя".


/* Definitions of the field level widgets                               */
DEFINE BUTTON Del-Filters
     LABEL "Снять доп. фильтр"
     SIZE 20 BY 1.

DEFINE BUTTON B-add
     LABEL "&Добав. орг"
     SIZE 12 BY 1.

DEFINE BUTTON B-add-prs
     LABEL "&Добав. чел"
     SIZE 12 BY 1.

DEFINE BUTTON B-attr
     LABEL "&Атрибуты"
     SIZE 9 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-bank
     LABEL "&Банки"
     SIZE 12 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Измен"
     SIZE 8 BY 1.

DEFINE BUTTON B-cont
     LABEL "Договор"
     SIZE 8 BY 1.

DEFINE BUTTON b-dc
     LABEL "Д.карты"
     SIZE 8 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удал"
     SIZE 8 BY 1.

DEFINE BUTTON B-docs
     LABEL "&Док-ты"
     SIZE 8 BY 1.

DEFINE BUTTON B-edi
     LABEL "&EDI"
     SIZE 9 BY 1 TOOLTIP "Параметры EDI".

DEFINE BUTTON B-grp
     LABEL "&Группа"
     SIZE 9 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 2 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 2 BY 1.

DEFINE BUTTON B-lkp
     LABEL "&Просм"
     SIZE 8 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-photo
     LABEL "&Фото"
     SIZE 9 BY 1.

DEFINE BUTTON B-price-type
     LABEL "&Цены"
     SIZE 8 BY 1 TOOLTIP "Список типов прайс-листов по клиенту".

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 2 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 8 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 2 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 12 BY 1.

DEFINE BUTTON b-sert
     LABEL "&Сертиф"
     SIZE 8 BY 1.

DEFINE BUTTON b-zak
     LABEL "&Заказы"
     SIZE 8 BY 1.

DEFINE BUTTON Goods-by-prod
     LABEL "Оборот&ы"
     SIZE 8 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 10.6 BY .67 NO-UNDO.

DEFINE VARIABLE NameOrCode AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 20.4 BY 1.05
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE All-Or-Group AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", "1",
"2", "2",
"3", "3"
     SIZE 24.4 BY 1 NO-UNDO.

DEFINE VARIABLE Cli-Status AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", "1",
"2", "2",
"3", "3"
     SIZE 36.6 BY 1 NO-UNDO.

DEFINE VARIABLE Cli-Types AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", "1",
"2", "2",
"3", "3",
"4", "4",
"5", "5",
"6", "6"
     SIZE 55.6 BY 1 NO-UNDO.

DEFINE VARIABLE Find-by AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", "1",
"2", "2",
"3", "3",
"4", "4"
     SIZE 28 BY 1 NO-UNDO.


DEFINE RECTANGLE RECT-All-or-Group
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 40.4 BY 1.33.

DEFINE RECTANGLE RECT-status
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 40.4 BY 2.

DEFINE RECTANGLE RECT-types
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 57.4 BY 3.52.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE NEW SHARED QUERY CLi-List FOR
                X_clients SCROLLING.


DEFINE NEW SHARED QUERY CLi-ListA FOR
                X_clients,
                X_clients-attr SCROLLING.


DEFINE NEW SHARED QUERY CLi-ListB FOR  X_clients,
      x_temp-list-buyer SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE CLi-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS CLi-List Dialog-Frame _FREEFORM
  QUERY CLi-List DISPLAY
      {&display-browse}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.33.

DEFINE BROWSE CLi-ListA
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS CLi-ListA Dialog-Frame _FREEFORM
  QUERY CLi-ListA NO-LOCK DISPLAY
      {&display-browse}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.33 ROW-HEIGHT-CHARS .67.

DEFINE BROWSE CLi-ListB
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS CLi-ListB Dialog-Frame _FREEFORM
  QUERY CLi-ListB NO-LOCK DISPLAY
      {&display-browse}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.33 ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 13
     B-sel AT ROW 1 COL 16
     B-bank AT ROW 1 COL 28
     B-docs AT ROW 1 COL 40
     Goods-by-prod AT ROW 1 COL 48
     b-dc AT ROW 1 COL 56
     b-zak AT ROW 1 COL 64
     b-sert AT ROW 1 COL 72
     B-attr AT ROW 1 COL 80
     b-hist AT ROW 1 COL 91
     b-print AT ROW 1 COL 93
     B-sch AT ROW 1 COL 95
     B-Help AT ROW 1 COL 97.6
     B-add AT ROW 2 COL 16
     B-add-prs AT ROW 2 COL 28
     B-lkp AT ROW 2 COL 40
     b-chg AT ROW 2 COL 48
     b-del AT ROW 2 COL 56
     B-price-type AT ROW 2 COL 64
     B-cont AT ROW 2 COL 72
     B-grp AT ROW 2 COL 80
     B-edi AT ROW 2 COL 89
     B-photo AT ROW 3 COL 89
     Find-by AT ROW 3.14 COL 12 NO-LABEL
     NameOrCode AT ROW 3.19 COL 39 COLON-ALIGNED NO-LABEL
     CLi-ListB AT ROW 4.52 COL 1.4
     CLi-ListA AT ROW 4.52 COL 1.4
     CLi-List AT ROW 4.52 COL 1.4
     All-Or-Group AT ROW 20.29 COL 74.2 NO-LABEL
     Del-Filters AT ROW 20.52 COL 35.2
     Cli-Types AT ROW 22 COL 2 NO-LABEL
     Cli-Status AT ROW 22.38 COL 60.4 NO-LABEL
     mark-num AT ROW 2.19 COL 1.6 NO-LABEL
     "Статус" VIEW-AS TEXT
          SIZE 14 BY .67 AT ROW 21.57 COL 70
          FGCOLOR 4 
     "Фильтры" VIEW-AS TEXT
          SIZE 14 BY .67 AT ROW 20.52 COL 9.4
          BGCOLOR 8 FGCOLOR 4 
     "Классификатор" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 20.29 COL 59.8
          FGCOLOR 4 
     "Поиск:" VIEW-AS TEXT
          SIZE 7.4 BY 1 AT ROW 3.19 COL 3.6
          FGCOLOR 4 
     RECT-status AT ROW 21.52 COL 59
     RECT-types AT ROW 20 COL 1.2
     RECT-All-or-Group AT ROW 20.05 COL 59
     SPACE(0.49) SKIP(2.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Клиенты"
         DEFAULT-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_clients B "NEW SHARED" ? ub clients
      TABLE: X_clients-attr B "NEW SHARED" ? ub clients-attr
      TABLE: X_firm B "NEW SHARED" ? ub firm
      TABLE: X_person B "NEW SHARED" ? ub person
      TABLE: X_shop B "NEW SHARED" ? ub shop
      TABLE: X_store B "NEW SHARED" ? ub store
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB CLi-ListB NameOrCode Dialog-Frame */
/* BROWSE-TAB CLi-ListA CLi-ListB Dialog-Frame */
/* BROWSE-TAB CLi-List CLi-ListA Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-attr:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-attr:HANDLE.

ASSIGN
       b-sert:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-sert:HANDLE.

ASSIGN
       Goods-by-prod:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-gds:HANDLE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE CLi-List
/* Query rebuild information for BROWSE CLi-List
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_clients NO-LOCK indexed-reposition.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE NEW SHARED QUERY CLi-List FOR
                X_clients SCROLLING.
     _END_FREEFORM_DEFINE
     _Query            is NOT OPENED
*/  /* BROWSE CLi-List */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE CLi-ListA
/* Query rebuild information for BROWSE CLi-ListA
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_clients NO-LOCK,
      EACH X_clients-attr OF x_clients NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE NEW SHARED QUERY CLi-ListA FOR
                X_clients,
                X_clients-attr SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE CLi-ListA */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE CLi-ListB
/* Query rebuild information for BROWSE CLi-ListB
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_clients NO-LOCK,
      first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR
            (x_temp-list-buyer.obj-type =   X_clients.obj-type AND
             x_temp-list-buyer.obj-code =   X_clients.obj-code)).
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE NEW SHARED QUERY CLi-ListB FOR  X_clients,
      x_temp-list-buyer SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE CLi-ListB */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* Клиенты */
DO:
run gbl/markqwa.p (
              input b-mark:sensitive
            , input v-rid-list) no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENDKEY OF FRAME Dialog-Frame /* Клиенты */
DO:
run gbl/markqwa.p (
              input b-mark:sensitive
            , input v-rid-list) no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Клиенты */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Клиенты */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Del-Filters
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Del-Filters Dialog-Frame
ON CHOOSE OF Del-Filters IN FRAME Dialog-Frame /* Дополнительно */
DO:
define variable g-log as logical   no-undo .

assign
      var-prev-br-name = var-br-name
      var-br-name = "cli-list"
      v-list-b = false
      ALL-Or-GROUP
      .
      g-log = ALL-Or-GROUP:enable ( radio-label ( {&attr}, ALL-Or-GROUP:radio-buttons) ).
  disable Del-Filters
  with frame {&frame-name} .
  assign
  All-Suppliers = FALSE
  SupGds = FALSE
  SupCons = FALSE
  SupServ = FALSE
  All-Buyers = FALSE
  BuyGds = FALSE
  BuyCons = FALSE
  BuyServ = FALSE
  JoinType = "NO"
  WLim-kr = FALSE
  f-turn-buyer =  false
  f-grp-buyer  =  false
  Find-By:screen-value = {&all}
  NameOrCode = ""
  .
  apply "value-changed" to Find-By in frame {&frame-name} .
{&APPLY-ENTRY}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME All-Or-Group
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL All-Or-Group Dialog-Frame
ON VALUE-CHANGED OF All-Or-Group IN FRAME Dialog-Frame
DO:
  run proc-value-change-all-or-group in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добав. орг */
DO:
run proc-b-add in this-procedure ( input yes /*фирма*/) no-error.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-prs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-prs Dialog-Frame
ON CHOOSE OF B-add-prs IN FRAME Dialog-Frame /* Добав. чел */
DO:
run proc-b-add in this-procedure ( input no /*чел*/) no-error.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr Dialog-Frame
ON CHOOSE OF B-attr IN FRAME Dialog-Frame /* Атрибуты */
DO:
 define variable v-updated as logical no-undo .
 define variable v-is-error as logical no-undo .
 define variable ri as recid no-undo  .
  if not available X_clients then do:
        return no-apply.
  end.
  ri = recid(X_clients).
  if attr-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if attr-option = "":U then do:
      return no-apply.
  end.
  if attr-option = {&LOOKUP}
  then do :
    g#log = NO.
  end .
  else do :
    CASE X_clients.obj-type :
      when {&cmp}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_client-reference_add-del':U
          {&cntxt-global}
          0
          '':U
          0
          0
          0
          0
          true
          g#log
        }
      end.
      when {&prs}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_client-reference-prs_add-del':U
          {&cntxt-global}
          0
          '':U
          0
          0
          0
          0
          true
          g#log
        }
      end.
      WHEN {&shop} OR WHEN {&stock} THEN DO:
          g#log = NO.
      END.
    END CASE.
  end .
  run ref/ca-attrr.p (
                    input parparentproc
                   ,input (if  NOT can-do( {&deleted} , Cli-Status )
                          then (if can-do( p-bttns, "b-add")
                               AND attr-option = {&update}
                               AND g#log
                               then {&update}
                               else {&lookup})
                          else {&lookup}
                        )
                   ,input X_clients.obj-type
                   ,input X_clients.obj-code
                   ,input yes /*p-update-on-exit*/
                   ,output v-updated
                   ,output v-is-error
                   ) no-error.
  if error-status:error
  or v-is-error then do:
    message
    "Ошибка при вызове списка атрибутов клиента" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box .
    assign
    attr-option = "":U
    .
    undo, return no-apply.
  end.
  if attr-option = {&update} and v-updated then do:
   if find-by = {&name} then do:
      apply "RETURN" to Nameorcode.
    end.
    else do:
      assign
      find-by = {&all}
      getc-recid = yes
      .
      display
      find-by
      with frame {&frame-name} .
      run proc-vc-find-by in this-procedure ( input no) no-error.
      if (X_clients.obj-type = {&prs}
                or X_clients.obj-type = {&cmp}
              )
            AND ri <> ? then do:
        {&run-openbr}
        {&reposition-to-ri}
        if error-status:error then do:
        &scop rr ri
          {&cant-positioning}.
        end.
      end.
    end.
  end.
  attr-option = "":U.
  {&apply-entry}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-bank Dialog-Frame
ON CHOOSE OF B-bank IN FRAME Dialog-Frame /* Банки */
DO:
define variable ri as recid no-undo.
define variable v-rid-list as character no-undo .
define variable v-status_ like ub.fin-schet.status_ no-undo init {&all}.
if available  X_clients then do:
  if X_clients.obj-type = {&stock}
  or X_clients.obj-type = {&shop} then do:
     message
     substitute("У &1 или &2 не может быть банков (банковских счетов)"
               , {&shop}
               , {&stock})
     view-as alert-box error .
     return no-apply.
  end.
  run ref/finschts.w (
                      INPUT parParentProc
                     ,input v-cntxt-host-code-obj
                     ,input "b-add":U
                     ,input "cmp-host":U
                     ,input X_clients.obj-type
                     ,input X_clients.obj-code
                     ,input ?
                     ,input v-cntxt-host-code-obj
                     ,input 0
                     ,input-output v-status_
                     ,input-output v-rid-list ).
end.
{&apply-entry}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Измен */
DO:
{ gbl/stdbtn.i }
define variable ri as recid no-undo.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_client-reference_update':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  g#log
}

if not g#log then return no-apply.
if not available X_clients then return no-apply.
ri = recid( X_clients ) .
c-recid = ri .
CASE X_clients.obj-type:
  when {&cmp}  then
      run ref/firmi.w (
                   input parParentProc
                  ,input ({&update} + (if v-s-deploy then (";":U + "s-deploy":U) else "":U))
                  ,input X_clients.obj-code
                  ,input X_clients.grp-code
                  ,input  "cli-all"
                  ,input-output  ri) .
  when {&prs} then
      run ref/personi.w (
                     input parParentProc
                    ,input {&update}
                    ,input X_clients.obj-code
                    ,input X_clients.grp-code
                    ,input "cli-all"
                    ,input-output  ri) .
  when {&shop} OR when {&stock}  then
      message "Изменение объектов типа ~"склад~" или ~"магазин~" "
                      "возможно только из АРМа ~"Администратор~"."
                      view-as alert-box INFORMATION .
END CASE .
if find-by = {&name} then do:
  apply "RETURN" to Nameorcode.
end.
else do:
  assign
  find-by = {&all}
  getc-recid = yes
  .
  display
  find-by
  with frame {&frame-name} .
  run proc-vc-find-by in this-procedure ( input no) no-error.
  if (X_clients.obj-type = {&prs}
            or X_clients.obj-type = {&cmp}
          )
        AND ri <> ? then do:
    {&run-openbr}
    {&reposition-to-ri}
    if error-status:error then do:
    &scop rr ri
      {&cant-positioning}.
    end.

  end.
end.
{&apply-entry}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cont
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cont Dialog-Frame
ON CHOOSE OF B-cont IN FRAME Dialog-Frame /* Договор */
DO:
   DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
    IF NOT AVAILABLE X_clients THEN RETURN NO-APPLY.
    run str/cont-all.w (
           input   parParentProc
          ,input   v-cntxt-host-code-obj
          ,input   ""
          ,input   {&company}
          ,input   X_clients.obj-type
          ,input   X_clients.obj-code
          ,input   ?
          ,input   ?
          ,input   "current"
          ,input   "all"
          ,input-output v-rid-list )
          .
  {&apply-entry}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dc Dialog-Frame
ON CHOOSE OF b-dc IN FRAME Dialog-Frame /* Д.карты */
DO:
   if not available X_clients then return no-apply.
     run ref/discards.w (
                    input parparentproc
                   ,input  "":U
                   ,input "client":u
                   ,input v-cntxt-host-code-obj
                   ,input v-cntxt-obj-type
                   ,input v-cntxt-obj-code
                   ,input '':U
                   ,input recid( X_clients )
                   ,output v-rid-list ) no-error .
     {&apply-entry}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удал */
DO:
define variable ri as recid no-undo .
if not avail X_clients then return no-apply.
ri = recid(X_clients).
run ref/clients2.p ( input parparentproc
                    ,input recid(X_clients)
                    ,input ? /*p-stts*/
                    ,input no /*p-silent*/
                    ,input no /*отсюда можно удалить только {&cmp} {&prs}*/
                    ,input '':U /*p-mode2*/
                    ,input '':U /*p-source-type*/
                    ,input '':U /*p-source-ref*/
                    ) no-error .
if error-status:error then do:
  return no-apply.
end.
{&run-openbr}
{&reposition-to-ri}
if error-status:error then do:
&scop rr ri
  {&cant-positioning}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-docs Dialog-Frame
ON CHOOSE OF B-docs IN FRAME Dialog-Frame /* Док-ты */
DO:
define variable doc-t as character no-undo.
DEFINE VARIABLE loc-ref-list as character no-undo.
define variable v-input-output as character no-undo .
define variable v-list-mode as character no-undo .
if not available X_clients then return no-apply.
run ref/doc-type.w ( output doc-t ) .
CASE doc-t :
  when "кон"  then
  v-list-mode = {&client-cmp}.
  when "мен"  then
  v-list-mode = "МЕНЕДЖЕР".
  when "исп"  then
  v-list-mode = "ИСПОЛНИТЕЛЬ".
  when "кла"  then
  v-list-mode = "КЛАДОВЩИК".
  otherwise do:
    return no-apply.
  end.
END CASE .

run str/all-docs.w (
               input parparentproc
              ,input v-cntxt-host-code-obj
              ,input v-cntxt-obj-type
              ,input v-cntxt-obj-code
              ,input v-list-mode
              ,input ? /*parstat*/
              ,input ? /*partype*/
              ,input ? /*parflag*/
              ,input ? /*parinternal*/
              ,input '':U /*bttns*/
              ,input '':U /*parext-doc-type*/
              ,input ? /*paris-hold*/
              ,input recid(X_clients)
              ,output loc-ref-list
              ) no-error .
              if error-status :error then message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                "Ошибка all-docs.w"
                view-as alert-box error
              .
  {&apply-entry}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-edi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-edi Dialog-Frame
ON CHOOSE OF B-edi IN FRAME Dialog-Frame /* EDI */
DO:
  define variable v-loc-rid-list as character no-undo .
  define variable v-uniq-key-rec as character no-undo .
    if not available X_clients then return no-apply.
  run gen-key-rec in this-procedure ( input {&table_clients}
                                     ,input ( buffer X_clients:handle)
                                     ,output v-uniq-key-rec).
  run cus/exiteedi.w (
                         INPUT parparentproc
                        ,INPUT  "" /*bttns*/
                        ,INPUT  "client"
                        ,INPUT  v-uniq-key-rec
                        ,input-output v-loc-rid-list  ) no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-grp Dialog-Frame
ON CHOOSE OF B-grp IN FRAME Dialog-Frame /* Группа */
DO:
define variable lns-cnt as integer no-undo .
define variable g-grp as character no-undo .
define variable v-gds-rec as recid no-undo.
define variable ri as recid no-undo .
define buffer buf_clients for ub.clients.
if not available X_clients then return no-apply.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_client-reference_update':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  g#log
}
if not g#log then return no-apply.
g#log = yes.
message
"Выберите группу, в которую нужно" skip
"переместить клиента(ов)."
view-as alert-box question buttons OK-Cancel update g#log.
if not g#log then   do:
        apply "entry" to Cli-List in frame {&frame-name}.
        return no-apply.
    end.
g-grp = "".
run ref/cli-grps.w (
                   input parparentproc
                 , input {&g#term} + ",b-sel"
                 , input-output g-grp ) .
if g-grp = "" then  do:
    {&apply-entry}
    return no-apply.
 end.
else do transaction:
    FIND ub.cli-grp where recid( ub.cli-grp ) = integer( g-grp ) .
    if v-rid-list = "" then
    v-rid-list = string( recid( X_clients ) ) .
    lns-cnt = 1.
    DO WHILE lns-cnt <= num-entries( v-rid-list ) :
        v-gds-rec = integer( entry( lns-cnt, v-rid-list ) ) .
        if lns-cnt = 1 then ri = v-gds-rec.
        FIND buf_clients where recid( buf_clients ) = v-gds-rec.
        buf_clients.grp-code = ub.cli-grp.node-code.
        lns-cnt = lns-cnt + 1.
    END .
    v-rid-list = "".
    mark-num = 0.
    hide mark-num in frame {&frame-name}.
end. /*end transaction*/
{&run-openbr}
{&reposition-to-ri}
if error-status:error then do:
&scop rr ri
  {&cant-positioning}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
define variable v-rid-list as character no-undo .
  if available X_clients THEN do:
    run ref/cclihist.w (
                      input parparentproc
                    , input 0 /*p-curr-host-code*/
                    , input "":U  /*p-curr-obj-type*/
                    , input 0  /*p-curr-obj-code*/
                    , input "":U /*bttns*/
                    , input "one":U /*p-mode*/
                    , input X_clients.obj-type /*p-obj-type*/
                    , input X_clients.obj-code /*p-obj-code*/
                    , input ? /*p-host-code*/
                    , input ? /* p-corr-user-db-num  */
                    , input "":U /* p-corr-user-name  */
                    , input "":U /* p-subject  */
                    , input v-cntxt-db-num /* p-db-num */
                    , input-output v-rid-list  ) no-error .

  END.
  {&apply-entry}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просм */
DO:
    RUN lkp-rec in this-procedure ( buffer X_clients ) no-error.
    {&apply-entry}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
if available X_clients then   do:
  { gbl/markstrn.i X_clients v-rid-list }
  if v-new-selection-flag then do:
    run choose-mark in this-procedure  no-error .
    if error-status :error
    then do:
      return no-apply .
    end.
  end.
  else do:
  {&refresh-br}
  if LOOKUP(last-event:function,  "MOUSE-SELECT-DBLCLICK, RETURN":U) = 0  then  do:
      {&select-next-row}
      {&apply-value-changed}
  end.
  if num-entries( v-rid-list ) = 0 then do:
      hide
      mark-num in
      frame {&frame-name}.
    end.
  else do:
      display
      num-entries( v-rid-list ) @ mark-num
      with frame {&frame-name}.
  end.
end.
end.
{&apply-entry}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-photo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-photo Dialog-Frame
ON CHOOSE OF B-photo IN FRAME Dialog-Frame /* Фото */
DO:
    if not available X_clients then return no-apply.
    run ref/cli-ph.p
      (input parparentproc
      ,buffer X_clients
      ) no-error .
    {&apply-entry}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-price-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-price-type Dialog-Frame
ON CHOOSE OF B-price-type IN FRAME Dialog-Frame /* Цены */
DO:
   define variable v-rid-list as character no-undo.
   if not available x_clients then return no-apply.
   run ref/c-tppr.p
   ( input parParentProc,
     input x_clients.obj-type ,
     input x_clients.obj-code ).
  {&apply-entry}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
run gbl/markqwa.p (
              input b-mark:sensitive
            , input v-rid-list) no-error.
if error-status:error then return no-apply.
assign
All-Or-Group
Cli-Status
Cli-Types .
c-added = trim( string( SupGds ) ) + {&comma-char} +
                 trim( string( SupCons ) ) + {&comma-char} +
                 trim( string( SupServ ) ) + {&comma-char} +
                 trim( string( BuyGds ) ) + {&comma-char} +
                 trim( string( BuyCons ) ) + {&comma-char} +
                 trim( string( BuyServ ) ) + {&comma-char} +
                 string( JoinType ) + {&comma-char} +
                                      {&comma-char} +
                 ( trim( string( WLim-kr ) ) )
                 .
assign
c-group = ( if All-Or-Group = {&all}
            then All-Or-Group
            else (if all-or-group = {&attr}
                  then ({&attr} + {&delim-key} + attr-option_)
                  else ({&group} + {&delim-key} + Curr-Grp-Name )
                 )
          )
c-status = Cli-Status
c-types = Cli-Types
c-recid = ( if available X_clients then recid( X_clients ) else ? )
v-uf-List_ = c-types + {&delim-par} +
           c-group + {&delim-par} +
           c-status + {&delim-par} +
           (if c-recid = ? then {&question-mark} else string(c-recid)) + {&delim-par} +
           c-added + {&delim-par} +
           c-other
v-uf-naim = (if browse cli-list:visible
             then (string(var-cli-name:width in browse cli-list) + {&delim-par} +
                   string(X_clients.grp-name:width in browse cli-list))
             else (string(var-cli-name:width in browse cli-lista) + {&delim-par} +
                  string(X_clients.grp-name:width in browse cli-lista))
             )
.
run uf-set in this-procedure (
    input  {&uf-cli-all-p}
    ,input v-cntxt-userid
    ,input v-uf-List_
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .

if can-do( p-bttns, "b-sel") then
    v-rid-list = "" .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
if v-rid-list = ""
or b-mark:sensitive = no
then do:
   if available X_clients then
   v-rid-list = string( recid( X_clients ) ) .
end.
if v-new-selection-flag then do:
  run choose-select in this-procedure  no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
end.
assign
All-Or-Group
Cli-Status
Cli-Types
.
c-added = ( trim( string( SupGds ) ) ) + {&comma-char} +
                 ( trim( string( SupCons ) ) ) + {&comma-char} +
                 ( trim( string( SupServ ) ) ) + {&comma-char} +
                 ( trim( string( BuyGds ) ) ) + {&comma-char} +
                 ( trim( string( BuyCons ) ) ) + {&comma-char} +
                 ( trim( string( BuyServ ) ) ) + {&comma-char} +
                 string( JoinType ) + {&comma-char} +
                                      {&comma-char} +
                 ( trim( string( WLim-kr ) ) )
                 .
assign
c-group = ( if All-Or-Group = {&all}
            then All-Or-Group
            else (if all-or-group = {&attr}
                  then ({&attr} + {&delim-key} + attr-option_)
                  else ({&group} + {&delim-key} + Curr-Grp-Name )
                 )
          )
c-status = Cli-Status
c-types = Cli-Types
c-recid = ( if available X_clients then recid( X_clients ) else ? )
.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sert Dialog-Frame
ON CHOOSE OF b-sert IN FRAME Dialog-Frame /* Сертиф */
DO:
   if not available X_clients then return no-apply.
   /* ???
   run gbl/pop-up.p ( input self :handle
                    , input no
                    ) no-error.
   if error-status :error then do:
      return no-apply.
   end.
   */
   if X_clients.obj-type <> {&stock} and X_clients.obj-type <> {&shop} then DO:
      case sert-option:
         when "m_sert":U THEN DO:
            run ref/cli-sert.w (
                     input parparentproc
                     ,input v-cntxt-obj-type
                     ,input v-cntxt-obj-code
                     ,input "cli"
                     ,input X_clients.obj-type
                     ,input X_clients.obj-code
                     ,input ? ) .
         END.
         when "m_licsupp":U THEN DO:
            run ref/licsupp.w ( input parparentproc
                              , input X_clients.obj-type
                              , input X_clients.obj-code
                              ) .
         END.
         when "m_licsale":U THEN DO:
            /* r u n ref/licsale.w ( input parparentproc
                              , input X_clients.obj-type
                              , input X_clients.obj-code
                              ) . */
         end.
         otherwise do:
         end.
      end case.
   end.
   else do:
      message "Нельзя заводить сертификаты и лицензии по объектам"
      view-as alert-box error.
   end.
    {&apply-entry}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-zak
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-zak Dialog-Frame
ON CHOOSE OF b-zak IN FRAME Dialog-Frame /* Заказы */
DO:
 DEFINE VARIABLE v-output as character no-undo .
define variable v-input-output as character no-undo .
if not available X_clients then return no-apply.
  run ref/all-zakz.w (
     input   parParentProc
    ,input   "all":U
    ,input   "all":U
    ,input   {&client-cmp}
    ,input   recid( X_clients )
    ,input   "b-lkp"
    ,input   ""
    ,output  v-output   ) .

  {&apply-entry}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME CLi-List
&Scoped-define SELF-NAME CLi-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CLi-List Dialog-Frame
ON ANY-PRINTABLE OF CLi-List IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CLi-List Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF CLi-List IN FRAME Dialog-Frame
DO:
  run br-mouse-select in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CLi-List Dialog-Frame
ON RETURN OF CLi-List IN FRAME Dialog-Frame
DO:
  run br-return in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CLi-List Dialog-Frame
ON VALUE-CHANGED OF CLi-List IN FRAME Dialog-Frame
DO:
  c-recid =  if available X_clients then recid( X_clients ) else ?  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME CLi-ListA
&Scoped-define SELF-NAME CLi-ListA
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CLi-ListA Dialog-Frame
ON ANY-PRINTABLE OF CLi-ListA IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CLi-ListA Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF CLi-ListA IN FRAME Dialog-Frame
DO:
    run br-mouse-select in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CLi-ListA Dialog-Frame
ON RETURN OF CLi-ListA IN FRAME Dialog-Frame
DO:
   run br-return in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CLi-ListA Dialog-Frame
ON VALUE-CHANGED OF CLi-ListA IN FRAME Dialog-Frame
DO:
  c-recid =  if available X_clients then recid( X_clients ) else ?  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME CLi-ListB
&Scoped-define SELF-NAME CLi-ListB
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CLi-ListB Dialog-Frame
ON ANY-PRINTABLE OF CLi-ListB IN FRAME Dialog-Frame
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CLi-ListB Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF CLi-ListB IN FRAME Dialog-Frame
DO:
    run br-mouse-select in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CLi-ListB Dialog-Frame
ON RETURN OF CLi-ListB IN FRAME Dialog-Frame
DO:
   run br-return in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CLi-ListB Dialog-Frame
ON VALUE-CHANGED OF CLi-ListB IN FRAME Dialog-Frame
DO:
  c-recid =  if available X_clients then recid( X_clients ) else ?  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Cli-Status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Cli-Status Dialog-Frame
ON VALUE-CHANGED OF Cli-Status IN FRAME Dialog-Frame
DO:
    assign
    getc-recid = yes
    Find-By:screen-value = {&all}
    NameOrCode = ""
    .
    apply "value-changed" to Find-By in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Cli-Types
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Cli-Types Dialog-Frame
ON VALUE-CHANGED OF Cli-Types IN FRAME Dialog-Frame
DO:
    assign
    v-is-prod = false
    Find-By:screen-value = {&all}
    NameOrCode = ""
    cli-types
    getc-recid = if (
                     cli-types = {&all} or
                     (avail X_clients and X_clients.is-prod and v-is-prod) OR
                     (avail X_clients and cli-types = X_clients.obj-type) or
                     (avail X_clients and (cli-types = {&g___object} or cli-types = "db") and (X_clients.obj-type = {&shop} or X_clients.obj-type = {&stock}))

                    ) then yes else no
    .
    case cli-types:
      when {&shop}
      or when {&stock}
      or when {&g___object}
      then do:
        assign
        X_clients.db-num:visible in browse cli-list = yes
        X_clients.host-code:visible in browse cli-list = yes
        X_clients.db-num:visible in browse cli-lista = yes
        X_clients.host-code:visible in browse cli-lista = yes
        X_clients.db-num:visible in browse cli-listb = yes
        X_clients.host-code:visible in browse cli-listb = yes
        .
      end.
      when "db" then do:
        assign
        X_clients.db-num:visible in browse cli-list = no
        X_clients.host-code:visible in browse cli-list = yes
        X_clients.db-num:visible in browse cli-lista = no
        X_clients.host-code:visible in browse cli-lista = yes
        X_clients.db-num:visible in browse cli-listb = no
        X_clients.host-code:visible in browse cli-listb = yes
        .
      end.
      otherwise do:
        assign
        X_clients.db-num:visible in browse cli-list = no
        X_clients.host-code:visible in browse cli-list = no
        X_clients.db-num:visible in browse cli-lista = no
        X_clients.host-code:visible in browse cli-lista = no
        X_clients.db-num:visible in browse cli-listb = no
        X_clients.host-code:visible in browse cli-listb = no
        .
      end.
    end case.
    apply "value-changed" to Find-By in frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Find-by
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Find-by Dialog-Frame
ON VALUE-CHANGED OF Find-by IN FRAME Dialog-Frame
DO:
   run proc-vc-find-by in this-procedure ( input yes) no-error.
   if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Goods-by-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Goods-by-prod Dialog-Frame
ON CHOOSE OF Goods-by-prod IN FRAME Dialog-Frame /* Обороты */
DO:
      if available X_clients then do:
            run gbl/pop-up.p ( input self:handle, input no) no-error.
        if error-status:error then return no-apply.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-gds-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-gds-1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m-gds-1 /* Товары по производителю */
DO:
    if available X_clients then do:
        run gdsbypr in this-procedure ( input recid(X_clients), input "Товары по производителю") no-error.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-gds-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-gds-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m-gds-2 /* Остатки по поставщику (партии) */
DO:
    if available X_clients then do:
        run gdsbypr in this-procedure( input recid(X_clients),  input "Остатки по поставщику (партии)") no-error.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-gds-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-gds-3 Dialog-Frame
ON CHOOSE OF MENU-ITEM m-gds-3 /* Остатки по поставщику (товары) */
DO:
    if available X_clients then do:
        run gdsbypr in this-procedure (  input recid(X_clients),  input "Остатки по поставщику (товары)") no-error.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-gds-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-gds-4 Dialog-Frame
ON CHOOSE OF MENU-ITEM m-gds-4 /* Обороты по поставщику (партии) */
DO:
    if available X_clients then do:
        run gdsbypr in this-procedure (  input recid(X_clients),   input "Обороты по поставщику (партии)") no-error.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-gds-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-gds-5 Dialog-Frame
ON CHOOSE OF MENU-ITEM m-gds-5 /* Обороты по поставщику (товары) */
DO:
    if available X_clients then do:
        run gdsbypr in this-procedure (  input recid(X_clients),  input "Обороты по поставщику (товары)") no-error.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-gds-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-gds-6 Dialog-Frame
ON CHOOSE OF MENU-ITEM m-gds-6 /* Обороты по контрагенту */
DO:
    if available X_clients then do:
        run gdsbypr in this-procedure (  input recid(X_clients),  input  "Обороты по контрагенту") no-error.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_licsupp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_licsupp Dialog-Frame
ON CHOOSE OF MENU-ITEM m_licsupp /* Лицензии на поставку алкоголя */
DO:
  assign
   sert-option = "m_licsupp":U
  .
  APPLY "CHOOSE" TO b-sert IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup-attr Dialog-Frame
ON CHOOSE OF MENU-ITEM m_lookup-attr /* Просмотр */
DO:
  assign
  ATTR-option = {&LOOKUP}
  .
  APPLY "CHOOSE" TO b-attr IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_sert
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_sert Dialog-Frame
ON CHOOSE OF MENU-ITEM m_sert /* Сертификаты */
DO:
  assign
    sert-option = "m_sert":U
  .
  APPLY "CHOOSE" TO b-sert IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_turnover-buyer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_turnover-buyer Dialog-Frame
ON CHOOSE OF MENU-ITEM m_turnover-buyer /* Обороты по покупателю */
DO:

define variable v-recid as character no-undo .
  if available X_clients then do:
     run ref/tov-br.w ( input parparentproc
                       ,input "b-add,b-chg,b-del"
                       ,input recid(X_clients)
                       ,output v-recid) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update-attr Dialog-Frame
ON CHOOSE OF MENU-ITEM m_update-attr /* Изменение */
DO:
  assign
  ATTR-option = {&UPDATE}
  .
  APPLY "CHOOSE" TO b-attr  IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME NameOrCode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL NameOrCode Dialog-Frame
ON LEAVE OF NameOrCode IN FRAME Dialog-Frame
DO:
{ gbl/stdbtn.i }
    assign
    NameOrCode
    .
 if last-event:function <> "RETURN" then  do:
   if ( NameOrCode = "" ) OR ( num-results( var-br-name ) = 0 ) then   do:
      assign
      Find-By:screen-value = {&all}
      NameOrCode = ""
      .
      /*{&run-openbr-false}*/
      DISABLE NameOrCode
      with frame {&frame-name} .
      HIDE NameOrCode .
      apply "value-changed" to Find-By in frame {&frame-name} .
  end.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL NameOrCode Dialog-Frame
ON RETURN OF NameOrCode IN FRAME Dialog-Frame
DO:
  run proc-return-nameorcode in this-procedure no-error .
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME CLi-List
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }
{ gbl/setfltnm.i }
/*{ ref/cli-all.i }*/
{ ref/cli-allh.i def }
{ ref/cli-allh.i procedures }


IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

g#log = cli-list:SET-REPOSITIONED-ROW(5, "CONDITIONAL").


/*перемещение колонок*/
{ gbl/mv-clmn.i
&browse-name = "cli-list"
&frame-name = "{&frame-name}"
&ext-col = 16
&start-column = 1}

{ gbl/brwrepos.i
&browse-name = "cli-list"
&line-num=5
}

{ gbl/brwrepos.i
&browse-name = "cli-listA"
&line-num=5
}

{ gbl/brwrepos.i
&browse-name = "cli-listB"
&line-num=5
}


/*перемещение колонок*/
{ gbl/mv-clmn.i
&browse-name = "cli-listA"
&frame-name = "{&frame-name}"
&ext-col = 16
&start-column = 1}

{ gbl/mv-clmn.i
&browse-name = "cli-listB"
&frame-name = "{&frame-name}"
&ext-col = 16
&start-column = 1}

{ gbl/brwrefre.i "run reopen-query in this-procedure no-error." }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run gbl/dftempl.p ( input "clients-attr":U, output template-recid) no-error.
    if error-status:error then dO:
      message
      vss-workfile vss-revision vss-description skip
      "Невозможно найти recid template записи в таблице clients-attr"
      view-as alert-box error .
      return error.
    end.
  assign
  filter-point0 = "cli-all"  + {&delim-par} + "Клиенты" + {&delim-par} + string(no)
  filter-point = filter-point0
  .
  v-rid-list = p-rid-list.
  FIND FIRST ub.sys-ctrl No-LOCK no-error.
  FIND FIRST ub.db WHERE ub.db.db-num = ub.sys-ctrl.db-num NO-LOCK .
  if lookup(c-other, "s-deploy":U, ";":U) > 0
  or lookup(c-other, "news":U, ";":U) > 0
  then do:
  { gbl/getcntxt.i get }
  end.
  else do:
   { gbl/getcntxt.i get }
  end.

  RUN StartProc  in this-procedure ( input 1).
  RUN Myenable.
  RUN StartProc  in this-procedure ( input 2).
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE br-mouse-select Dialog-Frame
PROCEDURE br-mouse-select :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if b-sel:sensitive in frame {&frame-name} then
  if b-mark:sensitive then
      apply "choose" to b-mark in frame {&frame-name}.
  else
      apply "choose" to b-sel in frame {&frame-name}.
  else
  if b-lkp:sensitive then
      apply "choose" to b-lkp in frame {&frame-name}.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE br-return Dialog-Frame
PROCEDURE br-return :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    if b-sel:sensitive in frame {&frame-name} then
        apply "choose" to b-sel in frame {&frame-name}.
    else
        if b-lkp:sensitive then
            apply "choose" to b-lkp in frame {&frame-name}.

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
  DISPLAY Find-by NameOrCode All-Or-Group Cli-Types Cli-Status mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-bank B-docs Goods-by-prod b-dc b-zak b-sert
         B-attr b-hist b-print B-sch B-Help RECT-status RECT-types
         RECT-All-or-Group B-add B-add-prs B-lkp b-chg b-del B-price-type
         B-cont B-grp B-edi B-photo Find-by NameOrCode CLi-ListB CLi-ListA
         CLi-List All-Or-Group Del-Filters Cli-Types Cli-Status mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gdsbypr Dialog-Frame
PROCEDURE gdsbypr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER rc as recid.
DEFINE INPUT PARAMETER calling as character.
define variable v-ri-list as character no-undo .
DEFINE VARIABLE v-output as character no-undo.
define variable v-input-output as character no-undo .
define variable v-from-date as date no-undo .
define variable v-to-date as date no-undo .
define variable glog as logical no-undo .
define buffer g-producer for ub.clients.
CASE calling:
  WHEN "Товары по производителю" THEN  do:
    if not X_clients.is-prod then do:
        message "Клиент не является производителем!" view-as alert-box WARNING.
        return error.
    end.
    FIND g-producer WHERE recid( g-producer ) = rc no-lock .
    run ref/gds-ref.p (
                   input  parparentproc
                  ,input  ""
                  ,input {&all}
                  ,input {&producer}
                  ,input {&all}
                  ,input ?
                  ,input ?
                  ,input g-producer.obj-type
                  ,input g-producer.obj-code
                  ,input ?
                  ,input ?
                  ,input ?
                  ,output v-ri-list ).
  end.
  WHEN "Остатки по поставщику (партии)" THEN DO:
    if not (X_clients.sup-gds OR X_clients.sup-cons) then do:
          message "Клиент не является поставщиком!" view-as alert-box WARNING.
          return error.
    end.
    run rep/supp-gds.w (
                          input parparentproc
                        ,input v-cntxt-obj-type
                        ,input v-cntxt-obj-code
                        ,input "stock"
                        ,input "current"
                        ,input X_clients.obj-type
                        ,input X_clients.obj-code).
  END.
  WHEN "Остатки по поставщику (товары)" THEN DO:
    if not (X_clients.sup-gds OR X_clients.sup-cons) then do:
      message "Клиент не является поставщиком!"
      view-as alert-box WARNING.
      return error.
    end.
    run ref/cli-gdss.w (
                    input parparentproc
                   ,input {&client-cmp_stock-cmp}
                   ,input ?
                   ,input rc
                   ) .
  END.
  WHEN "Обороты по поставщику (партии)" THEN DO:
    if not (X_clients.sup-gds OR X_clients.sup-cons) then do:
      message
      "Клиент не является поставщиком!"
      view-as alert-box WARNING.
      return error.
    end.
    run gbl/get-per.w ( output glog, input-output v-from-date, input-output v-to-date) .
    if not glog then return.
    run ref/vspartsr.p (
                    input parparentproc
                   ,input v-cntxt-obj-type
                   ,input v-cntxt-obj-code
                   ,input v-from-date
                   ,input v-to-date
                   ,input {&all}
                   ,input '':U
                   ,input recid(X_clients)
                   ) no-error .
  END.
  WHEN "Обороты по поставщику (товары)" THEN DO:
    if not (X_clients.sup-gds OR X_clients.sup-cons) then do:
      message
      "Клиент не является поставщиком!"
      view-as alert-box WARNING.
      return error.
    end.
    assign
    v-from-date = ?
    v-to-date = ?
    .
    run gbl/get-per.w ( output glog, input-output v-from-date, input-output v-to-date) .
    if not glog then return.
    run rep/v-suppl.w (
                   input parparentproc
                  ,input v-cntxt-obj-type
                  ,input v-cntxt-obj-code
                  ,input v-from-date
                  ,input v-to-date
                  ,input string(rc)
                  ).
  END.
  WHEN "Обороты по контрагенту" THEN DO:
    run ref/cli-gdss.w (
                    input parparentproc
                   ,input {&client-cmp_balance-cmp}
                   ,input ?
                   ,input rc
                   ).
  END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lkp-rec Dialog-Frame
PROCEDURE lkp-rec :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define parameter buffer bp-clients for ub.clients.

  if not available bp-clients THEN do:
    return.
  end.

  run ref/showcli.p (
     input parParentProc
    ,input bp-clients.obj-type /* p-obj-type */
    ,input bp-clients.obj-code /* p-obj-code */
    ).

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
ASSIGN  Cli-List:MAX-DATA-GUESS IN FRAME {&FRAME-NAME}     = 200.
ASSIGN  Cli-ListA:MAX-DATA-GUESS IN FRAME {&FRAME-NAME}     = 200.
ASSIGN  Cli-ListB:MAX-DATA-GUESS IN FRAME {&FRAME-NAME}     = 200.
ASSIGN
Goods-By-Prod:MENU-MOUSE = 1
b-attr:MENU-MOUSE in frame {&frame-name} = 1
b-sert:MENU-MOUSE in frame {&frame-name} = 1
.
assign
var-cli-name:resizable in browse cli-list = true
var-cli-name:width in browse cli-list = v-obj-name-width
X_clients.grp-name:resizable in browse cli-list = true
X_clients.grp-name:width in browse cli-list = v-grp-name-width
var-cli-name:resizable in browse cli-lista = true
var-cli-name:width in browse cli-lista = v-obj-name-width
X_clients.grp-name:resizable in browse cli-lista = true
X_clients.grp-name:width in browse cli-lista = v-grp-name-width
var-cli-name:resizable in browse cli-listb = true
var-cli-name:width in browse cli-listb = v-obj-name-width
X_clients.grp-name:resizable in browse cli-listb = true
X_clients.grp-name:width in browse cli-listb = v-grp-name-width

.
assign
All-Or-Group:radio-buttons =  "Все" + {&comma-char} + {&all} + {&comma-char} +
                              {&group} + {&comma-char} + {&group} + {&comma-char} +
                              "Привязка" + {&comma-char} + {&attr}
cli-status:radio-buttons = "Текущие&+ " + {&comma-char} + {&current} + {&comma-char} + "Все&!" + {&comma-char} + {&all} + {&comma-char} +
                           "Удаленные&-" + {&comma-char} + {&deleted}

CLi-types:Radio-buttons = "Вс&е" + {&comma-char} + {&all} + {&comma-char} + "&Орг" + {&comma-char} + {&cmp} + {&comma-char} +
                          "Фи&з.лица" + {&comma-char} + {&prs} + {&comma-char} +
                          "Об&ъ" + {&comma-char} + {&g___object} + {&comma-char} +
                          "Скл&" + {&comma-char} + {&stock} + {&comma-char} +
                          "&Маг" + {&comma-char} + {&shop} + {&comma-char} +
                          "&БД"  + {&comma-char} + "db"
FInd-By:radio-buttons = "Все" + {&comma-char} + {&all} + {&comma-char} + {&local-name} + {&comma-char} + {&name} + {&comma-char} +
                         {&local-code} + {&comma-char} + {&g___code} + {&comma-char} + "ИНН" + {&comma-char} + {&local-inn}
cli-listA:row = cli-list:row
cli-listA:column = cli-list:column
cli-listb:row = cli-list:row
cli-listb:column = cli-list:column
.
DISPLAY Find-by NameOrCode All-Or-Group Cli-Types Cli-Status mark-num
WITH FRAME {&frame-name} .
if v-is-news then do:
  disable
  all
  with frame {&frame-name} .
end.
ENABLE
b-quit RECT-status RECT-All-or-Group RECT-types B-sel
B-Help
Find-by NameOrCode
CLi-List Cli-Types Cli-Status
mark-num
WITH FRAME {&frame-name} .
if not v-is-news then do:
  ENABLE
  b-mark
  b-hist B-bank b-cont B-docs Goods-by-prod b-dc b-zak B-photo b-sch
  B-add B-add-prs B-grp b-chg B-lkp b-del b-print b-sert B-attr b-edi
  b-price-type
  CLi-ListA CLi-ListB All-Or-Group
  WITH FRAME {&frame-name} .
end.
VIEW FRAME {&frame-name} .
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

define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input  parameter p-needmes as logical no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define variable v-doc-rec as recid no-undo .
nameorcode = prep-nameorcode ( nameorcode).

title0 = "Список клиентов" + {&space-char}.
HIDE
CLi-ListA in frame {&frame-name}
CLi-ListB in frame {&frame-name}.
DISPLAY
CLi-LIST
with frame {&frame-name}.
if var-prev-br-name <> var-br-name then do:
  CASE var-prev-br-name:
    when '':U then do:
    end.
    when "cli-list" then do:
       close query cli-list.
    end.
    when "cli-lista" then do:
       close query cli-lista.
    end.
    when "cli-listb" then do:
       close query cli-listb.
    end.
  end case.
end.

&scop run-file   input  p-open-query ~
, input  p-find-next ~
,  input  p-find-condition ~
~
,  INPUT parParentProc ~
,  input attr-option_ ~
,  input show-as ~
,  input JoinType ~
,  input Cli-Types ~
,  input Curr-Grp-Name ~
,  input NameOrCode ~
,  input SupGds     ~
,  input SupCons    ~
,  input SupServ    ~
,  input BuyGds     ~
,  input BuyCons    ~
,  input BuyServ    ~
,  input WLim-kr    ~
,  input false      ~
,  input-output v-rid-list ~
~
,  input filter-point  ~
,  input filter-point0 ~
,  input sort-column-name ~
,  output v-filter-name ~
,  input-output v-doc-rec ~
~
) .

entry(1, filter-point, {&delim-par})  = entry(1, filter-point0 , {&delim-par}) + cli-types.
entry(2, filter-point, {&delim-par})  = entry(2, filter-point0 , {&delim-par}) + cli-types.

define variable log-res as logical no-undo.
RUn Switch-Buttons in this-procedure ( input p-needmes) No-ERROR.
if v-is-prod then do :
  show-as = {&pro} + left-trim(show-as,entry(1,show-as,"-")) .
end.

if show-as begins ({&pro} + "-" + {&all}) then do:
   run ref/cli-all1.p ({&run-file} /*change-Query-Pro*/.
end.
if show-as begins ({&pro} + "-" + {&name}) then do:
   run ref/cli-all2.p ({&run-file} /*change-Query-Pro  вторая часть*/.
end.
if show-as begins ({&all} + "-" + {&all}) then do:
  run ref/cli-all3.p ({&run-file}       /*RUN Change-Query-ALL in this-Procedure.*/
end.
if show-as begins ({&all} + "-" + {&name}) then do:
  run ref/cli-all4.p ({&run-file}         /*RUN Change-Query-ALL in this-Procedure.*/
end.
if show-as begins ("db" + "-") then do:
  if find-by = {&all} then do:
    run ref/cli-allm.p ({&run-file}
  end.
  else do:
    run ref/cli-alln.p ({&run-file}
  end.
end.
if show-as begins ({&g___object} + "-") then do:
  if find-by = {&all} then do:
    run ref/cli-allc.p ({&run-file}
  end.
  else do:
    run ref/cli-alld.p ({&run-file}
  end.
end.
else do:
  if (Cli-Types <> {&all}
  and cli-types <> "db"
     )
  and find-by = {&all} then do:
    run ref/cli-all5.p ({&run-file}
    /*RUN Change-Query-1 in this-Procedure.*/
  end.
  if (Cli-Types <> {&all}
  and cli-types <> "db"
      )
  AND find-by = {&name}  then do:
    run ref/cli-all6.p ({&run-file}
    /*RUN Change-Query-1 in this-Procedure.*/
  end.
end.

if p-NeedMes then  run waitfram-hide in this-procedure .
{ gbl/working.i }
HIDE
CLi-ListA in frame {&frame-name}
CLi-ListB in frame {&frame-name}.
assign
var-cli-name:width in browse cli-list = var-cli-name:width in browse cli-lista
X_clients.grp-name:width in browse cli-list = X_clients.grp-name:width in browse cli-lista
.
DISPLAY
CLi-LIST
with frame {&frame-name}.

run diasize_restore-orig-size in this-procedure .
run diasize_set-browse-handle in this-procedure
  (input browse CLi-list :handle
  ) .
run diasize_restore-current-size in this-procedure .

run set-filter-name in this-procedure (INPUT v-filter-name) no-error .
if num-results( "Cli-List" ) <> 0 then do:
    if c-recid <> ? then do:
       if not p-open-query
       or v-start
       then
       reposition Cli-List to recid( c-recid ) no-error .
    end.
    else do:
       if not p-open-query
       or v-start
       then
       reposition Cli-List to row 1 no-error .
       log-res = Cli-List:select-row( 1 ) in frame {&frame-name} .
    end.
    v-start = no.
end.
APPLY "VALUE-CHANGED" TO CLi-ListA  in frame {&frame-name}.
apply "entry" to Cli-List in frame {&frame-name} .
{ gbl/stopwork.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBrA Dialog-Frame
PROCEDURE OpenBrA :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input  parameter p-needmes as logical no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define variable v-doc-rec as recid no-undo .
title0 = "Список клиентов" + {&space-char}.
nameorcode = prep-nameorcode ( nameorcode).

if var-prev-br-name <> var-br-name then do:
  CASE var-prev-br-name:
    when '':U then do:
    end.
    when "cli-list" then do:
       close query cli-list.
    end.
    when "cli-lista" then do:
       close query cli-lista.
    end.
    when "cli-listb" then do:
       close query cli-listb.
    end.
  end case.
end.

&scop run-file   input  p-open-query ~
, input  p-find-next ~
,  input  p-find-condition ~
~
,  INPUT parParentProc ~
,  input attr-option_ ~
,  input show-as ~
,  input JoinType ~
,  input Cli-Types ~
,  input Curr-Grp-Name ~
,  input NameOrCode ~
,  input SupGds     ~
,  input SupCons    ~
,  input SupServ    ~
,  input BuyGds     ~
,  input BuyCons    ~
,  input BuyServ    ~
,  input WLim-kr    ~
,  input false     ~
,  input-output v-rid-list ~
~
,  input filter-point  ~
,  input filter-point0 ~
,  input sort-column-name ~
,  output v-filter-name ~
,  input-output v-doc-rec ~
~
) .

define variable log-res as logical no-undo.

RUn Switch-Buttons in this-procedure (  input p-needmes) No-ERROR.
if p-NeedMes then  run waitfram-hide in this-procedure .
if v-is-prod then do :
  show-as = {&pro} + left-trim(show-as,entry(1,show-as,"-")) .
end.

if show-as begins {&pro} then do:
   run ref/cli-all7.p ({&run-file}
   /*change-Query-Pro-A*/.
end.
else do:
   if show-as begins {&all} then do:
     run ref/cli-all9.p ({&run-file}
     /*RUN Change-Query-ALL-A in this-Procedure.*/
   end.
   else do:
     CASE entry(1, show-as, "-"):
       when {&g___object} then do:
          run ref/cli-alle.p ({&run-file}
       end.
       when "db":U then do:
          run ref/cli-allo.p ({&run-file}
       end.
       otherwise do:
         run ref/cli-allb.p ({&run-file}
         /*RUN Change-Query-1-A in this-Procedure.*/
       end.
     end CASE.
   end.
end.
{ gbl/working.i }
HIDE
CLi-list in frame {&frame-name}
CLi-listB
in frame {&frame-name}.
assign
var-cli-name:width in browse cli-lista = var-cli-name:width in browse cli-list
X_clients.grp-name:width in browse cli-lista = X_clients.grp-name:width in browse cli-list
.
DISPLAY
CLi-listA
with frame {&frame-name}.

run diasize_restore-orig-size in this-procedure .
run diasize_set-browse-handle in this-procedure
  (input browse CLi-listA :handle
  ) .
run diasize_restore-current-size in this-procedure .

run set-filter-name in this-procedure (INPUT v-filter-name) no-error .
if num-results( "Cli-ListA" ) <> 0 then do:
    if c-recid <> ? then do:
       if not p-open-query
       or v-start
       then
       reposition CLi-listA to recid( c-recid ) no-error .
    end.
    else do:
       if not p-open-query or
       v-start
       then
       reposition CLi-listA to row 1 no-error .
       log-res = CLi-listA:select-row( 1 ) in frame {&frame-name} .
    end.
    v-start = no.
end.
APPLY "VALUE-CHANGED" TO CLi-ListA  in frame {&frame-name}.
apply "entry" to CLi-listA in frame {&frame-name} .
{ gbl/stopwork.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBrB Dialog-Frame
PROCEDURE OpenBrB :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input  parameter p-needmes as logical no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define variable v-doc-rec as recid no-undo .
title0 = "Список Покупателей" + {&space-char}.
nameorcode = prep-nameorcode ( nameorcode).

if var-prev-br-name <> var-br-name then do:
  CASE var-prev-br-name:
    when '':U then do:
    end.
    when "cli-list" then do:
       close query cli-list.
    end.
    when "cli-lista" then do:
       close query cli-lista.
    end.
    when "cli-listb" then do:
       close query cli-listb.
    end.
  end case.
end.


&scop run-file   input  p-open-query ~
, input  p-find-next ~
,  input  p-find-condition ~
~
,  INPUT parParentProc ~
,  input attr-option_ ~
,  input show-as ~
,  input JoinType ~
,  input Cli-Types ~
,  input Curr-Grp-Name ~
,  input NameOrCode ~
,  input SupGds     ~
,  input SupCons    ~
,  input SupServ    ~
,  input BuyGds     ~
,  input BuyCons    ~
,  input BuyServ    ~
,  input WLim-kr    ~
,  input true     ~
,  input-output v-rid-list ~
~
,  input filter-point  ~
,  input filter-point0 ~
,  input sort-column-name ~
,  output v-filter-name ~
,  input-output v-doc-rec ~
~
) .

define variable log-res as logical no-undo.

RUn Switch-Buttons in this-procedure(  input p-needmes) No-ERROR.
if p-NeedMes then  run waitfram-hide in this-procedure .
if v-is-prod then do :
  show-as = {&pro} + left-trim(show-as,entry(1,show-as,"-")) .
end.
if show-as begins ({&pro} + "-" + {&all}) then do:
   run ref/cli-allh.p ({&run-file}
end.
if show-as begins ({&pro} + "-" + {&name}) then do:
   run ref/cli-allk.p ({&run-file}
end.
if show-as begins ({&all} + "-" + {&all}) then do:
  run ref/cli-alla.p ({&run-file}
end.
if show-as begins ({&all} + "-" + {&name}) then do:
  run ref/cli-allj.p ({&run-file}
end.
if show-as begins ("db" + "-") then do:
  if find-by = {&all} then do:
    run ref/cli-allp.p ({&run-file}
  end.
  else do:
    run ref/cli-allr.p ({&run-file}
  end.
end.
if show-as begins ({&g___object} + "-") then do:
  if find-by = {&all} then do:
    run ref/cli-alli.p ({&run-file}
  end.
  else do:
    run ref/cli-alls.p ({&run-file}
  end.
end.
else do:
  if (Cli-Types <> {&all}
  and Cli-Types <> "db"
  )
  and find-by = {&all} then do:
    run ref/cli-allf.p ({&run-file}
  end.
  if (Cli-Types <> {&all}
  and Cli-Types <> "db"
  )
  AND find-by = {&name}  then do:
    run ref/cli-allg.p ({&run-file}
  end.
end.

{ gbl/working.i }
HIDE
CLi-list in frame {&frame-name}
CLi-listA
in frame {&frame-name}.
assign
var-cli-name:width in browse cli-listb = var-cli-name:width in browse cli-list
X_clients.grp-name:width in browse cli-listb = X_clients.grp-name:width in browse cli-list
.
DISPLAY
CLi-listb
with frame {&frame-name}.

run diasize_restore-orig-size in this-procedure .
run diasize_set-browse-handle in this-procedure
  (input browse CLi-listb :handle
  ) .
run diasize_restore-current-size in this-procedure .

run set-filter-name in this-procedure ( INPUT v-filter-name) no-error .
if num-results( "Cli-Listb" ) <> 0 then do:
    if c-recid <> ? then do:
       if not p-open-query then
       reposition CLi-listb to recid( c-recid ) no-error .
    end.
    else do:
       if not p-open-query then
       reposition CLi-listb to row 1 no-error .
       log-res = CLi-listb:select-row( 1 ) in frame {&frame-name} .
    end.
end.
APPLY "VALUE-CHANGED" TO CLi-Listb  in frame {&frame-name}.
apply "entry" to CLi-listb in frame {&frame-name} .
{ gbl/stopwork.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-is-firm as logical no-undo.
DEFINE VARIABLE ri          as      recid   no-undo     init ? .
DEFINE VARIABLE to-grp      like  ub.cli-grp.node-code     no-undo .
define variable g-grp as character no-undo .

define buffer b-cli-grp for ub.cli-grp.
assign
Find-By:screen-value in frame {&frame-name} = {&all}  .
apply "value-changed" to Find-By in frame {&frame-name} .
CASE p-is-firm :
    when yes
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_client-reference_add-del':U
        {&cntxt-global}
        0
        '':U
        0
        0
        0
        0
        true
        g#log
      }
    end.
    when no
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_client-reference-prs_add-del':U
        {&cntxt-global}
        0
        '':U
        0
        0
        0
        0
        true
        g#log
      }
    end.
END CASE.
if not g#log then return error.
g-grp = "".
run ref/cli-grps.w (
                   input parparentproc
                  ,input "b-sel":U
                  ,input-output g-grp ) .
if g-grp <> "" then do:
  FIND ub.cli-grp where recid( ub.cli-grp ) = integer( g-grp ) .
  if can-find( FIRST b-cli-grp where b-cli-grp.upper-code = ub.cli-grp.node-code ) then do:
    message "Добавлять можно только в группы," skip
            "у которых нет подгрупп." skip
            "Выбирайте другую группу !"
    view-as alert-box WARNING .
    return no-apply .
  end.
  to-grp = ub.cli-grp.node-code .
  if p-is-firm then
      run ref/firmi.w (
                  input parParentProc
                 ,input ({&add-def} + (if v-s-deploy then (";":U + "s-deploy":U) else "":U))
                 ,input 0
                 ,input to-grp
                 ,input "cli-all"
                 ,input-output ri ) .
  else
      run ref/personi.w (
                    input parParentProc
                   ,input {&add-def}
                   ,input 0
                   ,input to-grp
                   ,input "cli-all"
                   ,input-output ri ) .
  if ri <> ? then do:
    if find-by <> {&all} then do:
      apply "RETURN" to Nameorcode.
    end.
    else do:
      {&run-openbr}
      {&reposition-to-ri}
      if error-status:error then do:
&scop rr ri
        {&cant-positioning}.
      end.
      {&apply-entry}
    end.
  end.
end.
else do:
  {&apply-entry}
  return no-apply.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.

define variable Line                as char         no-undo.
define variable CurrGroupName as char        no-undo.

define variable ii      as integer   no-undo.
define variable ri      as recid   no-undo.

DEFINE FRAME List
sym1 column-label ":" format "x(1)"
X_clients.obj-name column-label "Наименование" format "x(59)"
sym2 column-label ":" format "x(1)"
X_clients.obj-type column-label "Тип" format "x(8)"
sym3 column-label ":" format "x(1)"
X_clients.obj-code column-label "Код" format ">>>>>>>>>9"
sym4 column-label ":" format "x(1)"
X_clients.PS column-label "Примечание" format "x(40)"
sym5 column-label ":" format "x(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 86 format "X(15)" SKIP
Line format "x(130)" AT 1
with width {&DOS_CW} down use-text stream-io no-box .

if num-results( var-br-name ) = 0 then do:
  message "Список  П У С Т !" skip view-as alert-box information .
  return no-apply .
end.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reference-lists_print':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  false
  g#log
}

if not g#log then do:
    message
    "У Вас недостаточно прав для" skip
    "выполнения данного действия." skip
    "Обратитесь к администратору" skip
    "системы."
    view-as alert-box error title "Недостаточно прав !".
  return error .
end.
Line = fill( "-" , 140 ) .
assign frame {&frame-name}
All-Or-Group Cli-Types Cli-Status .
/* Это из-за того, что в QUERY Cli-List используется index reposition и,
как следствие, не работает GET first Cli-List  ( ошибка 3157 ) */
run waitfram-show in this-procedure ( {&MyWaitMess} ) .
ri = recid( X_clients ) .
case var-br-name :
when  "cli-list":U then do:
  DO WHILE available X_clients :
      GET prev Cli-List NO-LOCK .
  END.
  GET next Cli-List NO-LOCK .
end.
when "cli-listA":U then  do:
  DO WHILE available X_clients :
      GET prev Cli-ListA NO-LOCK .
  END.
  GET next Cli-ListA NO-LOCK .
end.
when "cli-listB":U then  do:
  DO WHILE available X_clients :
      GET prev Cli-ListB NO-LOCK .
  END.
  GET next Cli-ListB NO-LOCK .
end.

end case.
ii = 1 .

if All-Or-Group = {&group} then
CurrGroupName = X_clients.grp-name .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

FORM HEADER
Line format "X(130)" SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME CliBottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS no-box.
VIEW stream PrnLibStream FRAME CliBottomFrame .
PUT stream PrnLibStream space(30)
"С П И С О К   К Л И Е Н Т О В" format "X(100)" SKIP(2) .
FORM with frame List .
DO WHILE available X_clients :
    DISPLAY stream PrnLibStream
    sym1 X_clients.obj-name sym2 X_clients.obj-type
    sym3 X_clients.obj-code sym4 X_clients.PS sym5
    with frame List .
    DOWN stream PrnLibStream 1 with frame List .
    ii =  ii + 1 .
    if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
    run waitfram-show in this-procedure ( input ("Просмотрено строк : " + string( ii )) ) .
    if var-br-name = "cli-list":U then do:
        GET next Cli-List .
    end.
    else do:
        GET next Cli-ListA .
    end.
END.
run waitfram-hide in this-procedure .
PUT stream PrnLibStream Line format "X(130)" SKIP.
HIDE stream PrnLibStream FRAME CliBottomFrame .
output stream PrnLibStream close .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

{&reposition-to-ri}
if error-status:error then do:
&scop rr ri
      {&cant-positioning}.
end.
{&run-openbr-false}


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  tbl = 'clients'
  join-tbl = 'X_clients'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Клиент', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('obj-name', 'Название', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-prod', 'Пр-ль', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sup-gds', 'Пост-к/т', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sup-cons', 'Пост-к/к', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('buy-gds', 'Пок-ль/т', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('buy-cons', 'Пок-ль/к', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('buy-serv', 'Пок-ль/у', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('db-num', 'БД', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Своя фирма', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('grp-name', '', 'cligrp',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  /* RUN OpenBr(yes, no, '':U, yes). */
  if var-br-name = "" or var-br-name = ? then do:
    var-prev-br-name = var-br-name.
    var-br-name = "cli-list"  .
  end.
  {&run-openbr}
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find Dialog-Frame
PROCEDURE proc-find :
define input parameter cli-code like ub.clients.obj-code no-undo.
define output parameter par-recid as recid no-undo.

define buffer b-cli for ub.clients.
CASE Cli-Types :
  when {&all} then do:
    CASE JoinType :
      when "Или" then do:
         FIND FIRST b-cli WHERE
               b-cli.obj-code = cli-code AND
               ( if Cli-Status = {&current}
                  then b-cli.stts = 0
                  else if Cli-Status = {&deleted}
                     then b-cli.stts <> 0
                     else TRUE ) AND
               ( if All-Or-Group = {&group}
               then b-cli.grp-name begins Curr-Grp-Name
               else TRUE ) AND
               { ref/cli-qor.i b-cli}   NO-LOCK no-error .
      end. /*when ИЛИ*/
      when "NO" then do:
        FIND FIRST b-cli WHERE
               b-cli.obj-code = cli-code AND
               ( if Cli-Status = {&current}
                  then b-cli.stts = 0
                  else if Cli-Status = {&deleted} then b-cli.stts <> 0 else TRUE ) AND
               (if All-Or-Group = {&group}
                  then b-cli.grp-name begins Curr-Grp-Name
                  else TRUE )
         NO-LOCK no-error.
      end. /*when no*/
    END CASE . /*case joitype*/
  end. /* when {&all}*/
  otherwise do:
    CASE JoinType :
      when "Или" then do:
         FIND FIRST b-cli WHERE
               (cli-types = {&g___object} or b-cli.obj-type = Cli-Types) AND
               b-cli.obj-code = cli-code AND
               ( if Cli-Status = {&current}
                  then b-cli.stts = 0
                  else if Cli-Status = {&deleted} then b-cli.stts <> 0 else TRUE ) AND
               ( if All-Or-Group = {&group}
                  then b-cli.grp-name begins Curr-Grp-Name
                  else TRUE ) AND
               { ref/cli-qor.i b-cli}
         NO-LOCK no-error.
      end. /*when ИЛИ*/
      when "NO" then do:
         FIND FIRST b-cli WHERE
            (cli-types = {&g___object} or b-cli.obj-type = Cli-Types) AND
            b-cli.obj-code = cli-code AND
            ( if Cli-Status = {&current}
               then b-cli.stts = 0
               else if Cli-Status = {&deleted} then b-cli.stts <> 0 else TRUE ) AND
            ( if All-Or-Group = {&group}
               then b-cli.grp-name begins Curr-Grp-Name
               else TRUE )
         NO-LOCK no-error.
      end. /*when NO*/
    END CASE . /*case jointype*/
  end. /*otherwise*/
END CASE . /*when cli-types*/
if available b-cli then par-recid = recid(b-cli).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-findA Dialog-Frame
PROCEDURE proc-findA :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter cli-code like ub.clients.obj-code no-undo.
define output parameter par-recid as recid no-undo.

define buffer b-cli for ub.clients.

CASE Cli-Types :
  when {&all} then do:
    CASE JoinType :
      when "Или" then do:
         _ff1:
         FOR EACH b-cli WHERE
               b-cli.obj-code = cli-code AND
               ( if Cli-Status = {&current}
                  then b-cli.stts = 0
                  else if Cli-Status = {&deleted}
                     then b-cli.stts <> 0
                     else TRUE ) AND
               ( if All-Or-Group = {&group}
               then b-cli.grp-name begins Curr-Grp-Name
               else TRUE ) AND
               { ref/cli-qor.i b-cli}
         NO-LOCK:
            IF CAN-FIND(first clients-attr No-LOCK WHERE
                              clients-attr.obj-type = b-cli.obj-type AND
                              clients-attr.obj-code = b-cli.obj-code AND
                              clients-attr.attr-code = attr-option_) then LEAVE _ff1.
        end.
      end. /*when ИЛИ*/
      when "NO" then do:
        _ff2:
        FOR EACH b-cli WHERE
               b-cli.obj-code = cli-code AND
               ( if Cli-Status = {&current}
                  then b-cli.stts = 0
                  else if Cli-Status = {&deleted} then b-cli.stts <> 0 else TRUE ) AND
               (if All-Or-Group = {&group}
                  then b-cli.grp-name begins Curr-Grp-Name
                  else TRUE )
        NO-LOCK:
          IF CAN-FIND(first clients-attr No-LOCK WHERE
                           clients-attr.obj-type = b-cli.obj-type AND
                           clients-attr.obj-code = b-cli.obj-code AND
                           clients-attr.attr-code = attr-option_) then LEAVE _ff2.
        END. /*for each b-cli*/
      end. /*when no*/
      END CASE . /*case joitype*/
   end. /* when {&all}*/
   otherwise do:
     CASE JoinType :
       when "Или" then do:
         _ff5:
         FOR EACH b-cli WHERE
               b-cli.obj-type = Cli-Types AND
               b-cli.obj-code = cli-code AND
               ( if Cli-Status = {&current}
                  then b-cli.stts = 0
                  else if Cli-Status = {&deleted} then b-cli.stts <> 0 else TRUE ) AND
               ( if All-Or-Group = {&group}
                  then b-cli.grp-name begins Curr-Grp-Name
                  else TRUE ) AND
               { ref/cli-qor.i b-cli}
         NO-LOCK:
            IF CAN-FIND(first clients-attr No-LOCK WHERE
                              clients-attr.obj-type = b-cli.obj-type AND
                              clients-attr.obj-code = b-cli.obj-code AND
                              clients-attr.attr-code = attr-option_) then LEAVE _ff5.
         END. /*for each b-cli*/
       end. /*when ИЛИ*/
       when "NO" then do:
         _ff6:
         FOR b-cli WHERE
            b-cli.obj-type = Cli-Types AND
            b-cli.obj-code = cli-code AND
            ( if Cli-Status = {&current}
               then b-cli.stts = 0
               else if Cli-Status = {&deleted} then b-cli.stts <> 0 else TRUE ) AND
            ( if All-Or-Group = {&group}
               then b-cli.grp-name begins Curr-Grp-Name
               else TRUE )
         NO-LOCK:
            IF CAN-FIND(first clients-attr No-LOCK WHERE
                              clients-attr.obj-type = b-cli.obj-type AND
                              clients-attr.obj-code = b-cli.obj-code AND
                              clients-attr.attr-code = attr-option_) then LEAVE _ff6.
         END. /*for eahc b-cli*/
       end. /*when NO*/
     END CASE . /*case jointype*/
  end. /*otherwise*/
END CASE . /*when cli-types*/
if available b-cli then par-recid = recid(b-cli).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-return-nameorcode Dialog-Frame
PROCEDURE proc-return-nameorcode :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error
  :

    define variable cli-code like ub.clients.obj-code no-undo.
    define variable cli-name like ub.clients.obj-name no-undo.
    define variable ri as recid no-undo.
    assign
    frame {&frame-name} All-Or-Group
    Cli-Status Cli-Types Find-By NameOrCode
    .
    if NameOrCode = "" then
        return no-apply .
    if can-do( {&g___code} , Find-By ) then  do:
      assign
      cli-code = integer( trim( NameOrCode ) ) no-error
      .
      if error-status:error then do:
        message
        "Неверный код" skip
        "Введите цифровой код клиента длиной до 9 знаков включительно"
        view-as alert-box error .
        return error .
      end.

      if var-br-name = "cli-list" then do:
        run proc-find in this-procedure ( input cli-code, output ri) no-error.
      end.
      else do:
        run proc-findA in this-procedure ( input cli-code, output ri) no-error.
      end.
      if ri = ? then do:
          message "Клиент с кодом : " NameOrCode skip
                  "при текущих параметрах" skip
                  "просмотра справочника" skip
                  "НЕ  НАЙДЕН.".
          return no-apply.
       end.
       else  do:
          apply "entry" to NameOrCOde in frame {&frame-name} .
          /*
          assign
          Find-By:screen-value = {&all} .
          */
          run proc-vc-find-by in this-procedure ( input  no).
          {&reposition-to-ri}
          if error-status:error then do:
&scop rr ri
            {&cant-positioning}.
          end.
          {&SELECT-focused-ROW}
       end.
    end.
    else if Find-By = {&local-inn} then do:
      if var-br-name = "cli-list" then do:
        run proc-find-inn in this-procedure ( input trim( NameOrCode ), output ri) no-error.
        apply "entry" to NameOrCOde in frame {&frame-name} .
       
        {&reposition-to-ri}
        if error-status:error then do:
          if ri <> ? then do:
            &scop rr ri
            {&cant-positioning}.
          end.
          else do:
            message subst("Организации с ИНН &1 нет в справочнике", trim( NameOrCode ))
            view-as alert-box.
          end.
        end.
        {&SELECT-focused-ROW}
      end.
    end.
    
    else do:
      /*закоментарено NVB потому как непонятно почему раньше неработало - вроде работает все*/

      /*
      if trim( NameOrCode ) = "o" /* lat "o" */ OR
          trim( NameOrCode ) = "о" /* rus "о" */     then
          message 'Поиск по одной букве "о" НЕВОЗМОЖЕН !'
              view-as alert-box warning .
      else do:
      */
        NameOrCode = prep-nameorcode (nameorcode).
        {&run-openbr}
        if available X_clients AND num-results( var-br-name ) <> 0 then do:
            {&reposition-to-row-1}
            {&select-row-1}
        end.
      /*end.*/
    end.
  end.
  if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-value-change-All-or-Group Dialog-Frame
PROCEDURE proc-value-change-All-or-Group :
define variable g-grp as character no-undo .
  assign
  frame {&frame-name} ALL-Or-GROUP
  getc-recid = yes
  .
    CASE ALL-Or-GROUP:
      when {&group} then do:
        assign
          attr-option_ = ""
          var-prev-br-name = var-br-name
          var-br-name  = ( if var-br-name = "cli-listB":U then  "cli-listB":U else  "cli-list":U )
          g-grp        = "".
        run ref/cli-grps.w (  input parparentproc
                            ,input  "b-sel"
                            ,input-output g-grp ) .
        if g-grp = "" then do:
          assign All-Or-Group = {&all} .
          DISPLAY All-Or-Group with frame {&frame-name} .
        end.
        else do:
          FIND ub.cli-grp where recid( ub.cli-grp ) = integer( g-grp ) no-lock.
          RUN cli-grplib-get-full-name in this-procedure ( input ub.cli-grp.node-code, output Curr-Grp-Name ) .
          assign
          Find-By:screen-value = {&all}
          NameOrCode = "" .
          apply "value-changed" to Find-By in frame {&frame-name} .
        end.
      end.
      when {&attr} then do:
        assign
        attr-option_ = {&attr-db}
        var-prev-br-name = var-br-name
        var-br-name = ( if var-br-name = "cli-listB":U then  "cli-listB":U else  "cli-listA":U )
        g-grp = ""
        .
        assign
        Find-By:screen-value = {&all}
        NameOrCode = "" .
        apply "value-changed" to Find-By in frame {&frame-name} .
      end.
      when {&all} then do:
        assign
        Find-By:screen-value = {&all}
        NameOrCode = ""
        attr-option_ = ""
        var-prev-br-name = var-br-name
        var-br-name =  ( if var-br-name = "cli-listB":U then  "cli-listB":U else  "cli-list":U )
        g-grp = ""
        .
        apply "value-changed" to Find-By in frame {&frame-name} .
      end.
    END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-vc-find-by Dialog-Frame
PROCEDURE proc-vc-find-by :
define input parameter p-openquery as logical no-undo .
define variable PrevValue as char no-undo .
run waitfram-show in this-procedure ( input "Ждите..." ).
  do
  on error undo, return error
  :
    run waitfram-show in this-procedure ( input "Ждите..." ).
    PrevValue = Find-By .
    v-last-inn-rec = ?.
    assign
    frame {&frame-name}
    Find-By .
    c-recid = ( if available X_clients and getc-recid then recid( X_clients ) else ? ) .
    CASE Find-By :
      when 'все':U then do:
        g#log = Find-By:enable(radio-label('название':U, Find-by:radio-buttons)).
        g#log = Find-By:enable(radio-label('код':U, Find-by:radio-buttons)) .
        g#log = Find-By:enable(radio-label('ИНН':U, Find-by:radio-buttons)) .
        if p-openquery then do:
          {&run-openbr} .
        end.
        DISABLE
        NameOrCode
        with frame {&frame-name} .
        HIDE
        NameOrCode .
        run waitfram-hide in this-procedure .
        {&apply-entry}
      end.
      when 'название':U OR when 'код':U OR when 'ИНН' then do:
        VIEW
        NameOrCode .
        ENABLE
        NameOrCode
        with frame {&frame-name} .
        if can-do( 'код':U, Find-By ) AND
           can-do( 'название':U, PrevValue ) AND ( NameOrCode <> "" ) then do:
          if p-openquery then do:
            {&run-openbr}
          end.
        end.
        if can-do( 'код':U, Find-By ) then  do:
          assign
          NameOrCode:width-chars = 10
          NameOrCode:format = "x(9)" .
          g#log = Find-By:disable(radio-label('название':U, Find-by:radio-buttons)) .
          g#log = Find-By:disable(radio-label('ИНН':U, Find-by:radio-buttons)) .
        end.
        else if can-do( 'ИНН':U, Find-by ) then do:
            assign
            NameOrCode:width-chars = 15
            NameOrCode:format = "x(15)"
            .
            g#log = Find-by:disable (radio-label('название':U, Find-by:radio-buttons)) .
            g#log = Find-By:disable(radio-label('код':U, Find-by:radio-buttons)) .
        end.
        else do:
          assign
          NameOrCode:width-chars = 24.63
          NameOrCode:format = "X(40)"
          .
          g#log = Find-By:disable(radio-label('код':U, Find-by:radio-buttons)) .
          g#log = Find-By:disable(radio-label('ИНН':U, Find-by:radio-buttons)) .
        end.
        run waitfram-hide in this-procedure .
        apply "entry" to NameOrCode in frame {&frame-name} .
      end.
   END CASE .
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-query Dialog-Frame
PROCEDURE reopen-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable ri as recid no-undo .
if available X_clients then
ri = recid(X_clients).
{&run-openbr}
{&reposition-to-ri}
if error-status:error then do:
&scop rr ri
      {&cant-positioning}.
end.
{&apply-entry}
{&apply-value-changed}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE StartProc Dialog-Frame
PROCEDURE StartProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-step as integer no-undo .
define variable     list-buf    as  character    no-undo.

define variable custvalue            as character no-undo .
define variable custtype             as character no-undo .
define variable varis-fin as character no-undo .
DEFINE VARIABLE par-is-edi           as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo.
define variable v-str as character no-undo.
define variable v-cli-type like ub.clients.obj-type no-undo.
define variable v-cli-code like ub.clients.obj-code no-undo.
define variable g-log as logical no-undo.

if p-step = 1 then do:
  { gbl/conf-rd.i "'is-edi'" "''" "''" 0 "''" "''" "''" yes par-is-edi par-type }
  assign
  is-edi = lookup(par-is-edi, "true,yes":U) > 0
  .
  { gbl/conf-rd.i
  "'is-fin'"
  0
  "''"
  0
  "''"
  "''"
  "''"
  no
  varis-fin
  par-type
  no-error }
  assign
  is-fin = logical(varis-fin)
  .
  define variable v-use-grp-buy           as logical   no-undo .
  define variable v-use-oborot-buy        as logical   no-undo .
  define variable v-use-qnty-group        as logical   no-undo .
  define variable v-use-sum-group         as logical   no-undo .
  define variable v-use-add-code          as logical   no-undo .
  define variable v-use-sys-date-time     as logical   no-undo .
  define variable v-use-shift-date-num    as logical   no-undo .
  define variable v-use-cassa             as logical   no-undo .
  define variable v-use-val               as logical   no-undo .
  define variable v-use-pay-type          as logical   no-undo .
  define variable v-use-cash-pay          as logical   no-undo .
  define variable v-use-child as logical   no-undo .
  { gbl/glstall.i
    v-use-grp-buy
    v-use-oborot-buy
    v-use-qnty-group
    v-use-sum-group
    v-use-add-code
    v-use-sys-date-time
    v-use-shift-date-num
    v-use-cassa
    v-use-val
    v-use-pay-type
    v-use-cash-pay
    v-use-child
    }
/* А надо ли ?*/
if ( v-use-grp-buy or v-use-oborot-buy )  then   is-price-buyer = true .
  else  is-price-buyer = false  .
  if not v-is-news then do:
    run uf-get in this-procedure(
          input  {&uf-cli-all-p}
          ,input  v-cntxt-userid
          ,output v-uf-List_
          ,output v-uf-Naim
          ,output v-uf-print-graft
          ,output v-uf-sort-gr
          ,output v-uf-type-price
          ,output v-uf-type-val
      )  no-error.
      if not error-status:error
      and num-entries(v-uf-List_, {&delim-par}) = 6 then do:
        assign
        v-types  = entry(1, v-uf-List_, {&delim-par})
        v-group  = entry(2, v-uf-List_, {&delim-par})
        v-status = entry(3, v-uf-List_, {&delim-par})
        v-recid  = if entry(4, v-uf-List_, {&delim-par}) = {&question-mark}
                  then ?
                  else   integer(entry(4, v-uf-List_, {&delim-par}))
        v-added  = entry(5, v-uf-List_, {&delim-par})
        v-other  = entry(6, v-uf-List_, {&delim-par})
        .
        if num-entries(v-uf-Naim, {&delim-par}) >= 2 then do:
          assign
          v-obj-name-width = decimal(entry(1, v-uf-Naim, {&delim-par}))
          v-grp-name-width = decimal(entry(2, v-uf-Naim, {&delim-par}))
          .
        end.
      end.
    end.
    do ii = 1 to num-entries(c-other, ";":U):
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "without-obj":U then do:
        assign
        v-without-obj = yes
        .
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "news":U then do:
        assign
        v-is-news = yes
        .
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "lock-cli-type":U then do:
        assign
        v-lock-cli-type = yes
        .
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "s-deploy":U then do:
        assign
        v-s-deploy = yes
        .
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "parent-handle":U then do:
        assign
        p-callback-handle = handle(entry(2, entry(ii, c-other, ";":U), "=":U))
        .
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "supp-np":U then do:
        for each x_temp-list-buyer :
          delete x_temp-list-buyer.
        end.
        for each X_clients-attr no-lock where X_clients-attr.attr-code = {&attr-supp-np}
                                          and X_clients-attr.attr-value = "yes" :
              if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                                                         and x_temp-list-buyer.obj-code = X_clients-attr.obj-code)
              then do :
                create x_temp-list-buyer.
                assign
                  x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                  x_temp-list-buyer.obj-code = X_clients-attr.obj-code
                .
              end.
        end.
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "supp-lgas":U then do:
        for each x_temp-list-buyer :
          delete x_temp-list-buyer.
        end.
        for each X_clients-attr no-lock where X_clients-attr.attr-code = {&attr-supp-lgas}
                                          and X_clients-attr.attr-value = "yes" :
              if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                                                         and x_temp-list-buyer.obj-code = X_clients-attr.obj-code)
              then do :
                create x_temp-list-buyer.
                assign
                  x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                  x_temp-list-buyer.obj-code = X_clients-attr.obj-code
                .
              end.
        end.
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "supp-np-lgas":U then do:
        for each x_temp-list-buyer :
          delete x_temp-list-buyer.
        end.
        for each X_clients-attr no-lock where X_clients-attr.attr-code = {&attr-supp-np}
                                          and X_clients-attr.attr-value = "yes" :
              if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                                                         and x_temp-list-buyer.obj-code = X_clients-attr.obj-code)
              then do :
                create x_temp-list-buyer.
                assign
                  x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                  x_temp-list-buyer.obj-code = X_clients-attr.obj-code
                .
              end.
        end.
        for each X_clients-attr no-lock where X_clients-attr.attr-code = {&attr-supp-lgas}
                                          and X_clients-attr.attr-value = "yes" :
              if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                                                         and x_temp-list-buyer.obj-code = X_clients-attr.obj-code)
              then do :
                create x_temp-list-buyer.
                assign
                  x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                  x_temp-list-buyer.obj-code = X_clients-attr.obj-code
                .
              end.
        end.
      end.
      if  entry(1, entry(ii, c-other, ";":U), "=":U) = "tank-farm-for":U then do :
        if entry(2, entry(ii, c-other, ";":U), "=":U) <> "":U
        then do:
          v-tank-farm-for = entry(2, entry(ii, c-other, ";":U), "=":U).
          do jj = 1 to num-entries(v-tank-farm-for)  :
            v-str = entry(jj,v-tank-farm-for).
            v-cli-type = substring(v-str,1,3).
            v-cli-code = integer(trim(v-str,v-cli-type)).
            find first X_clients no-lock
                where X_clients.obj-type = v-cli-type
                  and X_clients.obj-code = v-cli-code no-error.
            if available X_clients then do :
              if v-rid-list = "" then do :
                v-rid-list = string( recid(X_clients) ).
              end.
              else do :
                v-rid-list = v-rid-list + "," + string( recid(X_clients) ).
              end.
            end.
          end.
        end.
      end.
      if  entry(1, entry(ii, c-other, ";":U), "=":U) = "auto-tank-for":U then do :
        if entry(2, entry(ii, c-other, ";":U), "=":U) <> "":U
        then do:
          v-auto-tank-for = entry(2, entry(ii, c-other, ";":U), "=":U).
          do jj = 1 to num-entries(v-auto-tank-for) :
            v-str = entry(jj,v-auto-tank-for).
            v-cli-type = substring(v-str,1,3).
            v-cli-code = integer(trim(v-str,v-cli-type)).
            find first X_clients no-lock
                where X_clients.obj-type = v-cli-type
                  and X_clients.obj-code = v-cli-code no-error.
            if available X_clients then do :
              if v-rid-list = "" then do :
                v-rid-list = string( recid(X_clients) ).
              end.
              else do :
                v-rid-list = v-rid-list + "," + string( recid(X_clients) ).
              end.
            end.
          end.
        end.
      end.
      if  entry(1, entry(ii, c-other, ";":U), "=":U) = "auto-tank-for-supp":U then do :
        if entry(2, entry(ii, c-other, ";":U), "=":U) <> "":U
        then do:
          v-auto-tank-for-supp = entry(2, entry(ii, c-other, ";":U), "=":U).
          for each X_clients-attr no-lock where X_clients-attr.attr-code = {&attr-auto-tank-for}
                                            and lookup(v-auto-tank-for-supp,X_clients-attr.attr-value) <> 0 :
            if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                                                        and x_temp-list-buyer.obj-code = X_clients-attr.obj-code)
            then do :
              create x_temp-list-buyer.
              assign
                x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                x_temp-list-buyer.obj-code = X_clients-attr.obj-code
              .
            end.
          end.
        end.
      end.
      if  entry(1, entry(ii, c-other, ";":U), "=":U) = "tank-farm-for-supp":U then do :
        if entry(2, entry(ii, c-other, ";":U), "=":U) <> "":U
        then do:
          v-tank-farm-for-supp = entry(2, entry(ii, c-other, ";":U), "=":U).
          do jj = 1 to num-entries(v-tank-farm-for-supp) :
            v-str = entry(jj,v-tank-farm-for-supp).
            for each X_clients-attr no-lock where X_clients-attr.attr-code = {&attr-tank-farm-for}
                                              and X_clients-attr.attr-value = v-str :
              if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                                                          and x_temp-list-buyer.obj-code = X_clients-attr.obj-code)
              then do :
                create x_temp-list-buyer.
                assign
                  x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                  x_temp-list-buyer.obj-code = X_clients-attr.obj-code
                .
              end.
            end.
          end .
        end.
        else do :
          for each X_clients-attr no-lock where X_clients-attr.attr-code = {&attr-tank-farm-for}
                                            and X_clients-attr.attr-value > "" :
            if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                                                        and x_temp-list-buyer.obj-code = X_clients-attr.obj-code)
            then do :
              create x_temp-list-buyer.
              assign
                x_temp-list-buyer.obj-type = X_clients-attr.obj-type
                x_temp-list-buyer.obj-code = X_clients-attr.obj-code
              .
            end.
          end.
        end .
      end.
      if entry(1, entry(ii, c-other, ";":U), "=":U) = "contract-edi_orders":U then do:
        for each x_temp-list-buyer :
          delete x_temp-list-buyer.
        end.

        for each X_contract-attr no-lock where X_contract-attr.attr-code = "contract-edi_orders" and
        X_contract-attr.host-code = v-cntxt-host-code-obj and
        X_contract-attr.attr-value = string(true):
            for first X_contractr no-lock where 
                      X_contractr.contract-code = X_contract-attr.contract-code
                  and X_contractr.host-code = X_contract-attr.host-code
                  and X_contractr.doc-type = {&income}
                  and X_contractr.status_ = {&current-contr}
                  and (X_contractr.contract-date-end >= today or X_contractr.contract-date-end = ?)
                  and X_contractr.contract-date-beg <= today
              :
              if not can-find (first x_temp-list-buyer where x_temp-list-buyer.obj-type = X_contractr.cli-type
                                                         and x_temp-list-buyer.obj-code = X_contractr.cli-code)
              then do :
                create x_temp-list-buyer.
                assign
                  x_temp-list-buyer.obj-type = X_contractr.cli-type
                  x_temp-list-buyer.obj-code = X_contractr.cli-code
                .
              end.                
            end.
        end.    
      end.
    end.
    /*для пущей корректности*/
    if v-cntxt-level <> {&cntxt-object} then do:
      assign
      v-without-obj = yes
      .
    end.
    /* запрашиваем список объектов */
    if (lookup("b-mark", p-bttns) > 0
     or lookup("b-mark-hidden", p-bttns) > 0)
    and valid-handle(p-callback-handle)
    and lookup( "userobjs_transfer", p-callback-handle:internal-entries ) > 0
    then do:
      v-new-selection-flag = yes.
      run userobjs_transfer in p-callback-handle
        (input this-procedure :handle
        ) .

      run display-select-num in this-procedure .
    end.
    else do:
      hide mark-num in frame {&frame-name}.
    end.
    return.
end.
if v-other begins "tank-farm-for" or v-other begins "auto-tank-for" or v-other begins "supp-np" or v-other begins "supp-lgas" or v-other begins "contract-edi_orders" then v-other = "".
if c-types = {&pro} then do :
  c-types = ? .
  v-is-prod = true.
end.
assign
c-types  =  (if c-types = ? then v-types else c-types)
c-group  =  (if c-group = ? then v-group else c-group)
c-status =  (if c-status = ? then v-status else c-status)
c-recid  =  (if c-recid = ? then v-recid else c-recid)
c-added  =  (if c-added = ? then v-added else c-added)
c-other  =  (if c-other = ? then v-other else c-other)
.
DISABLE
b-Photo 
b-sel   when (lookup("b-sel", p-bttns) = 0)
b-add   when (lookup("b-add", p-bttns) = 0)
b-add-prs   when (lookup("b-add", p-bttns) = 0)
b-chg   when (lookup("b-add", p-bttns) = 0)
b-grp   when (lookup("b-add", p-bttns) = 0)
b-sert  when ((lookup("b-add", p-bttns) = 0) and v-cntxt-db-num <> 0)
b-del   when (lookup("b-add", p-bttns) = 0)
b-bank  when (lookup("b-bank", p-bttns) = 0)
b-mark  when (lookup("b-mark", p-bttns) = 0)
cli-types when v-lock-cli-type
b-edi     when not is-edi
b-cont    when not is-fin
b-price-type   when not is-price-buyer
WITH FRAME {&frame-name}.

CASE entry( 1, c-added ) :
        when "yes" then
            SupGds = yes .
        when "no" OR when "" then
            SupGds = no .
        when "?" then
            SupGds = ? .
END CASE .
CASE entry( 2, c-added ) :
        when "yes" then
            SupCons = yes .
        when "no" OR when "" then
            SupCons = no .
        when "?" then
            SupCons = ? .
END CASE .
CASE entry( 3, c-added ) :
        when "yes" then
            SupServ = yes .
        when "no" OR when "" then
            SupServ = no .
        when "?" then
            SupServ = ? .
END CASE .
CASE entry( 4, c-added ) :
        when "yes" then
            BuyGds = yes .
        when "no" OR when "" then
            BuyGds = no .
        when "?" then
            BuyGds = ? .
END CASE .
CASE entry( 5, c-added ) :
        when "yes" then
            BuyCons = yes .
        when "no" OR when "" then
            BuyCons = no .
        when "?" then
            BuyCons = ? .
END CASE .
CASE entry( 6, c-added ) :
        when "yes" then
            BuyServ = yes .
        when "no" OR when "" then
            BuyServ = no .
        when "?" then
            BuyServ = ? .
END CASE .

list-buf = entry( 9, c-added ) NO-ERROR .
if error-status:error OR ( list-buf = "yes" ) then
    WLim-kr = TRUE .
else
    WLim-kr = FALSE .
assign
JoinType = entry( 7, c-added )
All-Or-Group = if num-entries(c-group, {&delim-key}) > 1
               then entry(1, c-group, {&delim-key})
               else {&all}
Curr-Grp-Name = if num-entries(c-group, {&delim-key}) > 1
                then entry(2, c-group, {&delim-key})
                else ""
attr-option_ = (if all-or-group = {&attr}
                and num-entries(c-group, {&delim-key}) > 1
                and entry(2, c-group, {&delim-key}) <> "":U
                then entry(2, c-group, {&delim-key})
                else "")
Cli-Status = c-status
Cli-Types = c-types
All-Suppliers = ( SupGds OR SupCons OR SupServ )
All-Buyers = ( BuyGds OR BuyCons OR BuyServ ) .

do ii = 1 to num-entries(c-other, ";":U):
  if entry(1, entry(ii, c-other, ";":U), "=":U) = "auto-tank-for":U or entry(1, entry(ii, c-other, ";":U), "=":U) = "tank-farm-for":U  then do :
    if entry(2, entry(ii, c-other, ";":U), "=":U) = "":U then v-rid-list = "".
  end.
  else do :
    v-total-select-num = num-entries(v-rid-list).
  end.
end.
DISPLAY
All-Or-Group
Cli-Status
Cli-Types
WITH FRAME {&frame-name} .
case cli-types:
  when {&shop}
  or when {&stock}
  or when {&g___object}
  then do:
    assign
    X_clients.db-num:visible in browse cli-list = yes
    X_clients.host-code:visible in browse cli-list = yes
    X_clients.db-num:visible in browse cli-lista = yes
    X_clients.host-code:visible in browse cli-lista = yes
    X_clients.db-num:visible in browse cli-listb = yes
    X_clients.host-code:visible in browse cli-listb = yes
    .
  end.
  when "db" then do:
    assign
    X_clients.db-num:visible in browse cli-list = no
    X_clients.host-code:visible in browse cli-list = yes
    X_clients.db-num:visible in browse cli-lista = no
    X_clients.host-code:visible in browse cli-lista = yes
    X_clients.db-num:visible in browse cli-listb = no
    X_clients.host-code:visible in browse cli-listb = yes
    .
  end.
  otherwise do:
    assign
    X_clients.db-num:visible in browse cli-list = no
    X_clients.host-code:visible in browse cli-list = no
    X_clients.db-num:visible in browse cli-lista = no
    X_clients.host-code:visible in browse cli-lista = no
    X_clients.db-num:visible in browse cli-listb = no
    X_clients.host-code:visible in browse cli-listb = no
    .
  end.
end case.

if attr-option_ = "":U then do:
    HIDE
    cli-listA
    in frame {&frame-name}.
end.
else do:
    HIDE
    cli-list
    in frame {&frame-name}.
end.
if v-total-select-num = 0 then do:
  HIDE
  mark-num
  in frame {&frame-name} .
end.
HIDE
NameOrCode
in frame {&frame-name} .
if attr-option_ = "":U then do:
  var-prev-br-name = var-br-name.
  var-Br-Name = "cli-list":U.
  { gbl/brwrepos.i
   &browse-name=cli-list
   &line-num=5
   }
end.
else do:
  var-prev-br-name = var-br-name.
  var-Br-Name = "cli-listA":U.
  { gbl/brwrepos.i
    &browse-name=cli-listA
    &line-num=5
   }
end.

if entry(1,c-other,"=":U) = "supp-lgas"
or entry(1,c-other,"=":U) = "supp-np"
or entry(1,c-other,"=":U) = "supp-np-lgas"
or entry(1,c-other,"=":U) = "auto-tank-for-supp"
or entry(1,c-other,"=":U) = "tank-farm-for-supp"
or entry(1,c-other,"=":U) = "contract-edi_orders"
then do :
  HIDE
  CLi-list in frame {&frame-name}
  CLi-listA
  in frame {&frame-name}.

  enable Del-Filters
  with frame {&frame-name} .

  g-log = ALL-Or-GROUP:disable ( radio-label ( {&attr}, ALL-Or-GROUP:radio-buttons) ).
  var-prev-br-name = var-br-name.
  var-Br-Name = "cli-listB":U.
  v-list-b = true .
  { gbl/brwrepos.i
    &browse-name=cli-listB
    &line-num=5
   }
end.
{&run-openbr}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Switch-Buttons Dialog-Frame
PROCEDURE Switch-Buttons :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-needmes as logical no-undo .
define variable titleStr as character no-undo.
titleStr = "Клиенты".
{ gbl/working.i }

VIEW
b-add in frame {&frame-name}
b-add-prs in frame {&frame-name}
b-bank b-del b-grp b-mark b-sel b-chg
b-Docs Goods-By-Prod b-Hist b-Photo b-Print b-lkp b-help b-dc b-attr b-cont
in frame {&frame-name} .

if p-NeedMes then
run waitfram-show in this-procedure (  input "Подождите : таблица ОБНОВЛЯЕТСЯ." ) .

assign frame {&frame-name}
All-Or-Group Cli-Types Cli-Status Find-By
.



CASE Cli-Types :
    when {&all} then
        TitleStr = "Все клиенты " .
    when {&cmp} then
        TitleStr = "Все организации  " .
    when {&prs} then
        TitleStr = "Все физич. лица " .
    when {&stock} then
        TitleStr = "Все склады " .
    when {&shop} then
        TitleStr = "Все магазины " .
    when {&g___object} then
        TitleStr = "Все объекты " .
    when "db" then
        TitleStr = "Все объекты текущей БД" .


END CASE .
if v-is-prod then TitleStr = "Все производители" .
if can-do( {&group} , All-Or-Group ) then
    TitleStr = TitleStr + "группы " + substr( Curr-Grp-Name, 1, 40 ) + {&space-char}.
if can-do( {&attr} , All-Or-Group ) then
    TitleStr = TitleStr + "Атрибут " + attr-option_.

CASE Cli-Status :
    when {&current} then
        TitleStr = TitleStr + "( текущие )" .
    when {&deleted} then
        TitleStr = TitleStr + "( удаленные )" .
END CASE .

if JoinType <> "NO" then
    TitleStr = TitleStr + ". С доп. фильтром." .

if entry(1,c-other,"=":U) = "supp-np"
then TitleStr = TitleStr + {&space-char} + "Поставщики НП" .
else
if entry(1,c-other,"=":U) = "supp-lgas"
then TitleStr = TitleStr + {&space-char} + "Поставщики СУГ" .
else
if entry(1,c-other,"=":U) = "contract-edi_orders"
then TitleStr = TitleStr + {&space-char} + "Поставщики с контрактом EDI" .
else
if entry(1,c-other,"=":U) = "supp-np-lgas"
then TitleStr = TitleStr + {&space-char} + "Поставщики НП и СУГ" .
if entry(1,c-other,"=":U) = "auto-tank-for-supp"
then TitleStr = TitleStr + {&space-char} + "Является перевозчиком для:" + v-auto-tank-for-supp .
if entry(1,c-other,"=":U) = "tank-farm-for-supp"
then TitleStr = TitleStr + {&space-char} + "Является нефтебазой/ГНС для:" + v-tank-farm-for-supp.
frame {&frame-name}:title = TitleStr .
show-as = Cli-Types + "-" + Find-By + "-" + All-Or-Group + "-" + Cli-Status .
if ub.db.add-clients /*AND
can-do( {&all} , Cli-Types ) AND
can-do( {&all} + {&comma-char} + {&attr} , All-Or-Group ) AND
( NOT can-do( {&deleted} , Cli-Status ) ) AND
can-do( "NO", JoinType ) */  AND NOT TRANSACTION then do:
 ENABLE
 b-add   when can-do( p-bttns, "b-add")
 b-add-prs   when can-do( p-bttns, "b-add")
 b-chg   when can-do( p-bttns, "b-add")
 b-grp   when can-do( p-bttns, "b-add")
 b-del   when can-do( p-bttns, "b-add")
 b-attr  when can-do( p-bttns, "b-add")
 WITH FRAME {&frame-name} .
 end.
else do:
 DISABLE
 b-add
 b-add-prs
 b-chg
 b-grp
 b-del
 b-attr
 WITH FRAME {&frame-name} .
end.
if db.add-clients AND
( NOT can-do( {&deleted} , Cli-Status ) ) AND
can-do( "NO", JoinType ) AND NOT TRANSACTION then do:
 ENABLE
 b-chg   when can-do( p-bttns, "b-add")
 b-grp   when can-do( p-bttns, "b-add") AND not can-do( {&group} , Cli-Types )
 WITH FRAME {&frame-name} .
 if lookup("b-add", p-bttns) > 0 then menu-item m_update-attr:sensitive in menu menu-b-attr = yes .
end.
else do:
 DISABLE
 b-chg
 b-grp
 WITH FRAME {&frame-name} .
 menu-item m_update-attr:sensitive in menu menu-b-attr = no .
end.
if NOT TRANSACTION
then do:
    ENABLE
    b-attr
    WITH FRAME {&frame-name} .
end.
else do:
    DISABLE
    b-attr
    WITH FRAME {&frame-name} .
end.
if v-without-obj and not v-s-deploy then do:
  DISABLE
  b-dc
  b-del
  b-docs
  b-grp
  b-sert
  b-zak
  goods-by-prod
  b-edi
  WITH FRAME {&frame-name}.
  assign
  b-bank:label = "&Счета".
end.
if v-s-deploy or v-is-news then do:
  DISABLE
  b-add-prs
  b-dc
  b-del
  b-docs
  b-sert
  b-zak
  goods-by-prod
  b-edi
  b-sch
  b-attr
  all-or-group
  b-bank
  b-cont
  WITH FRAME {&frame-name}.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

 
&IF DEFINED(EXCLUDE-proc-find-inn) = 0 &THEN
		
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-inn Dialog-Frame
procedure proc-find-inn:
define input parameter par-inn as character no-undo.
define output parameter par-recid as recid no-undo.

define buffer b_clients for ub.clients.
define buffer b_firm for ub.firm.

if v-last-inn-rec <> ? then do:
    
    find first b_firm no-lock
        where recid(b_firm) = v-last-inn-rec
        no-error.    
            
    if not available b_firm then do:
        v-last-inn-rec = ?.
        par-recid = ?.
        return.
    end.
    
    find next b_firm no-lock
        where b_firm.inn = par-inn
        no-error.
    
    if not available b_firm then do:        
        find first b_firm no-lock
            where b_firm.inn = par-inn
            no-error.
        find first b_clients no-lock
            where b_clients.obj-code = b_firm.firm-code
            and b_clients.obj-type = {&cmp}
            no-error.
        
        v-last-inn-rec = recid(b_firm).
        par-recid = recid(b_clients).
    end.
end.
else do:
    find first b_firm no-lock
        where b_firm.inn = par-inn
        no-error.
    
    if not available b_firm then do:
        v-last-inn-rec = ?.
        par-recid = ?.
        return.
    end.
end.
        
find first b_clients no-lock
    where b_clients.obj-type = {&cmp}
    and b_clients.obj-code = b_firm.firm-code
    no-error.

if not available b_clients then do:
    v-last-inn-rec = ?.
    par-recid = ?.
    return.
end.

par-recid = recid(b_clients).
v-last-inn-rec = recid(b_firm).

end procedure.
	
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-client Dialog-Frame
FUNCTION get-client RETURNS CHARACTER
  (buffer loc_clients for clients  ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable var-cli-name as character no-undo.
define buffer buf_dis-card             for ub.dis-card.
define buffer buf_buyer-in-buyer-group for ub.buyer-in-buyer-group  .
define buffer buf_buyer-group          for ub.buyer-group  .

var-cli-name = (IF (loc_clients.stts = 0)
                       THEN (loc_clients.obj-name)
                       ELSE (substring (
                                                loc_clients.obj-name, 1, 25) +
                                                FILL (" " , 25 - LENGTH (substring (loc_clients.obj-name, 1, 25)) )) +
                                                {&deleted-stat_}
                                 ).
    FIND buf_dis-card WHERE
         buf_dis-card.cli-type = X_clients.obj-type AND
         buf_dis-card.cli-code = X_clients.obj-code NO-LOCK NO-ERROR .
    if available buf_dis-card then
        assign
            cli-dcard = buf_dis-card.d-card
            cli-dpcnt = buf_dis-card.d-pcnt .
    else
        assign
            cli-dcard = ""
            cli-dpcnt = 0 .

RETURN var-cli-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( buffer loc_clients for clients, input mark-list as character ) :
define buffer buf_dis-card for ub.dis-card.
define buffer buf_buyer-in-buyer-group for ub.buyer-in-buyer-group  .
define buffer buf_buyer-group          for ub.buyer-group  .
define variable v-mark-string as character no-undo .

var-cli-name = (IF (loc_clients.stts = 0)
                       THEN (loc_clients.obj-name)
                       ELSE (substring (
                                                loc_clients.obj-name, 1, 25) +
                                                FILL (" " , 25 - LENGTH (substring (loc_clients.obj-name, 1, 25)) )) +
                                                {&deleted-stat_}
                                 ).
    FIND buf_dis-card WHERE
         buf_dis-card.cli-type = X_clients.obj-type AND
         buf_dis-card.cli-code = X_clients.obj-code NO-LOCK NO-ERROR .
    if available buf_dis-card then
        assign
            cli-dcard = buf_dis-card.d-card
            cli-dpcnt = buf_dis-card.d-pcnt .
    else
        assign
            cli-dcard = ""
            cli-dpcnt = 0 .

    find first buf_buyer-in-buyer-group no-lock where
               buf_buyer-in-buyer-group.stts = 0 and
               buf_buyer-in-buyer-group.bbg-obj-type = X_clients.obj-type and
               buf_buyer-in-buyer-group.bbg-obj-code = X_clients.obj-code no-error .
    if available buf_buyer-in-buyer-group then do:
    find first buf_buyer-group no-lock where
               buf_buyer-group.stts = 0 and
               buf_buyer-group.bgr-db-num = buf_buyer-in-buyer-group.bgr-db-num and
               buf_buyer-group.bgr-id     = buf_buyer-in-buyer-group.bgr-id no-error .
    assign
     price-grp = buf_buyer-group.name
    .
    end.
    else assign
     price-grp = ""
    .
  if v-new-selection-flag then do:
    run get-mark-string in this-procedure
      (input  loc_clients.obj-type
      ,input  loc_clients.obj-code
      ,output v-mark-string
      ) .
    return v-mark-string .

  end.
RETURN ( IF LOOKUP( STRING( recid(loc_clients)), mark-list ) > 0 THEN "*" ELSE "":U ).


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION prep-nameorcode Dialog-Frame
FUNCTION prep-nameorcode RETURNS CHARACTER
  ( input p-nameorcode as character ) :
define variable v-nameorcode as character no-undo .
if trim(p-nameorcode) = '' then  return ''.
v-nameorcode = trim( trim( p-NameOrCode) , "*" ) .
if index(v-NameOrCode, {&double-quote} ,1 ) = 1
and R-index(v-NameOrCode, {&double-quote} ,1 ) = 1 then do:
  assign
  v-NameOrCode = trim(v-NameOrCode, {&double-quote})
  .
  nameorcode = v-nameorcode.
  display NameOrCode with frame {&frame-name}.
end.
/*
v-NameOrCode = right-trim( v-NameOrCode, "o" ) .    /* lat "o" */
v-NameOrCode = right-trim( v-NameOrCode , "о" ) /* rus "о" */ + "*" .
*/
define variable v-dopi as character no-undo .
assign
v-dopi = substring(v-NameOrCode, length(v-NameOrCode), 1)
.
if index("abcdefghijklmnopqrstuvwxyzабвгдеёжзийклмнопрстуфхцчшщъыьэюя", v-dopi) > 0
or index("1234567890", v-dopi) > 0
then do:
  v-NameOrCode = v-NameOrCOde + "*".
end.
v-NameOrCode = LC(v-NameOrCode).

RETURN v-nameorcode.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME