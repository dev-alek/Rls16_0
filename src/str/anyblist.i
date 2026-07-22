/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматизированное формирование списка разнообразнейших бар-кодов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/09/05
Author: Bakhtadze Natalya
Creation date: 02/09/05

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Автоматизированное формирование списка разнообразнейших бар-кодов".
{ cmp/vssrevis.i }

&scop add-operation 1
&scop del-operation 2
&scop rest-operation 3
&scop cancel-operation 4
&SCOPED-DEFINE called send-codes-only

&scop browse-name br-list

&scop FRAME-NAME     Dialog-Frame

&scop codes-labels ~
(if t-loc-base then 'основн.'  else '':U) + ~{&space-char~} +                           ~
(if t-bc-base  then 'основн.EAN'  else '':U) + ~{&space-char~} +                        ~
(if t-bc-alt then 'неосновн.EAN'  else '':U) + ~{&space-char~} +                           ~
(if t-loc-alt  then 'неосновн.'  else '':U) + ~{&space-char~} +                      ~
(if t-pb-base then 'ДопБК основн.'  else '':U) + ~{&space-char~} +                      ~
(if t-pb-alt then 'ДопБК неосновн.'  else '':U) + ~{&space-char~} +                     ~
(if t-sc-base then 'весов. и топл.'  else '':U) + ~{&space-char~} +                     ~
(if t-all-prt then 'все признаки'  else '':U) + ~{&space-char~} +                       ~
(if t-parts-ser then 'на сер. товар'  else '':U) + ~{&space-char~} +                    ~
(if t-parts-not-blank then 'на непуст. № парт.'  else '':U) + ~{&space-char~} +         ~
(if t-parts-all then 'все партии'  else '':U)

&scop codes-values ~
(if t-loc-base then 'loc-base':U  else '':U) + ~{&space-char~} +                        ~
(if t-bc-base  then 'bc-base':U  else '':U) + ~{&space-char~} +                         ~
(if t-bc-alt then 'bc-alt':U  else '':U) + ~{&space-char~} +                            ~
(if t-loc-alt  then 'loc-alt':U  else '':U) + ~{&space-char~} +                         ~
(if t-pb-base then 'pb-base':U  else '':U) + ~{&space-char~} +                          ~
(if t-pb-alt then 'pb-alt':U  else '':U) + ~{&space-char~} +                            ~
(if t-sc-base then 'sc-base'  else '':U) + ~{&space-char~} +                            ~
(if t-all-prt then 'all-prt'  else '':U) + ~{&space-char~} +                            ~
(if t-parts-ser then 'parts-ser':U  else '':U) + ~{&space-char~} +                      ~
(if t-parts-not-blank then 'parts-not-blank'  else '':U) + ~{&space-char~} +            ~
(if t-parts-all then 'parts-all'  else '':U)


&scop open-br open query br-list for each {1} no-lock indexed-reposition.
&scop disp-hot-fields ~
  if available {1} then do: ~
    find ub.clients where ub.clients.obj-type = {1}.prod-type ~
                   and ub.clients.obj-code = {1}.prod-code no-lock. ~
    find ub.gds-prt where ub.gds-prt.upper-code = {1}.prt-root no-lock. ~
    find ub.bar-code where ub.bar-code.gds-code  = {1}.gds-code ~
                    and ub.bar-code.node-code = ub.gds-prt.node-code ~
                    and ub.bar-code.unit-cli  = {1}.unit-base ~
                    and ub.bar-code.in-code   = "" ~
                    and ub.bar-code.part-code = "" no-lock. ~
    disp ub.clients.obj-name ub.gds-prt.node-name ub.bar-code.b-code tot-lns @ f-tot-lns with frame {&frame-name}. ~
  end. ~
  disp tot-lns @ f-tot-lns with frame {&frame-name}.

&scop OPEN-BR-option open query br-option for each temp-list no-lock .

&if defined(all-options) = 0 &then

&scop all-options                                 ~
"Текущая строка,single,                           ~
Товары-коды по типам,goods,                       ~
Товар-лок.код,goods-b-code,                       ~
Товар-лок.код(EAN),goods-b-code-ean,              ~
Товар-Доп.БК,goods-b-str,                         ~
Бар-код в чеке-последний чек,last-check,           ~
Все выключенные ДопБк,prod-bc-off,                ~
Коды на кассе,cd-codes,                           ~
Лок.коды просроч.партий своб.зоны,parts-last-date,         ~
Лок.коды просроч.зарезерв. партий,parts-rsrv-last-date,    ~
Лок.коды(EAN) просроч.партий своб.зоны,parts-ean-last-date,         ~
Лок.коды(EAN) просроч.зарезерв. партий,parts-ean-rsrv-last-date,    ~
Лок.коды ФиБ партий своб.зоны,parts-fib,         ~
Лок.коды зарезерв ФиБ партий,parts-rsrv-fib,    ~
Лок.коды(EAN) ФиБ партий своб.зоны,parts-ean-fib,         ~
Лок.коды(EAN) зарезерв. ФиБ партий,parts-ean-rsrv-fib,    ~
Лок.коды товаров с продажей по партиям,parts-cashparts,         ~
Лок.коды (EAN)товаров с продажей по партиям,parts-ean-cashparts,         ~
Лок.коды законч.на объ.партий,parts-end-date-obj,         ~
Лок.коды(EAN) законч.на объ.партий,parts-ean-end-date-obj,         ~
Лок.весовые коды в БД,loc-sc-codes,          ~
Лок.штучные коды для весов в БД,loc-pg-codes,          ~
Глоб.весовые коды,gbl-sc-codes,          ~
Файл списка товаров,file-gds,                     ~
Фильтр баркодов,filter,                           ~
Все,all,                                          ~
Список товаров,gds-list,                          ~
Мобильн. сканер,scaner"

&endif

&glob no-browser-option 'optimize':U

/* ***************************  Definitions  ************************** */

define new shared variable body-handle as handle no-undo.
{ cmp/showinf.i }
DEFine new shared VARiable RS-list-method AS CHARACTER.
define variable lns-ignore as integer no-undo .
define variable v-seq as integer no-undo .
define variable v-no-hist as integer no-undo init -1.
define variable lns-cnt as integer no-undo .
define variable v-num-add          as integer no-undo .
define variable v-num-ignored      as integer no-undo .
define variable v-no-obj as logical no-undo .
define variable v-rid-list as character no-undo .
define variable g#report-num as integer no-undo .
define buffer buf_clients for ub.clients.
define variable v-user-select as logical no-undo .
define variable v-sel-obj-type like ub.clients.obj-type no-undo .
define variable v-sel-obj-code like ub.clients.obj-code no-undo .
define buffer buf_user-obj for ub.user-obj.
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable v-notcd as logical no-undo init yes.


{ cmp/bb-list.i {1} def shared }
{ cmp/gds-list.i gds-list def "new shared" }
{ str/bc-gnrt.i new bc }
{ str/listhprc.i {1}  }
{ str/libbcrcn.i }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ cmp/r-pril.i new }
{ str/tsdtmpdt.i }
{ gbl/userobjs.i }
{ cmp/pbc-list.i pbc-list def  "new" }
{ cmp/bc-list.i bc-list def  "new" }


define temp-table temp_recid-list no-undo
    field string-goods-recid as character
    index pi is primary unique string-goods-recid
.

define temp-table temp-list no-undo
field fname as character format "X(30)"
field fvalue as character
field id as integer
index pi is primary unique
id
index ifvalue fvalue
.

{ cmp/listhist.i macro-list "new shared" }


define variable f-name as char init "default.gds" no-undo.
define variable f-gds-name as char init "default.gds" no-undo.
define variable f-cli-name as char init "default.cli" no-undo.
define variable f-doc-name as char init "default.trn" no-undo.

define variable conf-par             as character           no-undo.    /* для чтения параметра конфигурации */
define variable par-type             as character           no-undo.    /* тип параметра конфигурации */

define variable grp-list             as character           no-undo.
define variable ref-list             as character           no-undo.
define variable num-rec              as integer     init 0  no-undo.
define variable tot-lns              as integer     init ?  no-undo.
define variable v-ext-button-label   as character           no-undo.
DEFINE VARIABLE v-attr-code          as character           no-undo .
DEFINE VARIABLE vvalue               as character           no-undo .
DEFINE VARIABLE vvalue1              as character           no-undo .
define variable vvaluedec            as decimal             no-undo .
DEFINE VARIABLE vtype                as character           no-undo .
DEFINE VARIABLE v-host-code          like ub.sysconf.host-code no-undo .
define variable v-date               as date                no-undo .
define variable is-tsd               as logical             no-undo .
define variable v-notes as character no-undo .
define variable v-ref-rec as recid no-undo .
define variable line-mode as character no-undo .
define variable line-rec as recid no-undo .
define variable contin as logical init no.

define variable glog                as logical             no-undo .
define variable g#log                as logical             no-undo .
define variable main-b-code like ub.bar-code.b-code no-undo .
define variable action as character no-undo init "U":U.
/*флаг топливного товара*/
DEFINE VARIABLE petrol-trk                   as logical          no-undo .
/*флаг продажи по партияи*/
DEFINE VARIABLE cashparts                    like ub.gds-obj.cash-parts no-undo .
/*текущий объект = ресторан*/
define variable v-is-restaurant              as logical no-undo .
define variable v-is-null-price              like ub.fbr-gds-obj.is-null-price  no-undo .
define buffer l-{1} for {1}. /* для поиска  */
define variable l-empty-scale as logical no-undo .
/*количество на складе*/
DEFINE VARIABLE for-fact-qnty                like ub.gds-obj.fact-qnty no-undo .
define variable new-good                     as logical no-undo .
define variable v-chk-date as date no-undo .
define variable v-chk-date-chr as character no-undo .
define variable i-obj-type as character no-undo .
define variable i-obj-code like ub.clients.obj-code no-undo .
define variable v-doc-prt as logical no-undo .
define variable v-pos-type like ub.cash-desk.pos-type no-undo .
define variable v-cash-num like ub.cash-desk.cash-num no-undo .
define variable v-cash-desk-obj-code like ub.cash-desk.obj-code no-undo .
define variable optimize-option as character no-undo.
define variable optimize-label  as character no-undo.
define variable v-curr-obj-type like ub.clients.obj-type no-undo .
define variable v-curr-obj-code like ub.clients.obj-code no-undo .
define stream slog.

define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.

&scop NEW-GOOD  assign ~
                new-good = yes ~
                petrol-trk = no ~
                cashparts = no ~
                main-b-code = 0 ~
                .



define stream sout.

{ gbl/flt-def.i }
{ gbl/fltfield.i }
&glob bbc bbc

FUNCTION stat-line RETURNS CHARACTER
  (input p-status-chr as character )  FORWARD.
/* ***********************  Control Definitions  ********************** */

DEFINE MENU m-save
      MENU-ITEM m-gds-save       LABEL "Файл списка товаров"
      MENU-ITEM m-bb-save       LABEL "Файл списка кодов"
&if "{1}" = "scnblist" &then
      MENU-ITEM m-scn-save      LABEL "Файл мобильного сканера"
&else
      MENU-ITEM m-scn-save      LABEL "Файл ТСД"
&endif
      MENU-ITEM m-xls-save      LABEL "Таблица EXCEL"
      MENU-ITEM m-title-save    LABEL "Имя Списка"
      MENU-ITEM m-macros-save   LABEL "Макрос формирования списка"
      RULE
      MENU-ITEM m-cd            LABEL "Передача на кассу"
      .


DEFINE MENU m-optimize
      MENU-ITEM m-repnprod-bc  LABEL "Замена локальных кодов на ДопБК (если они есть в системе)"
      MENU-ITEM m-delnprod-bc  LABEL "Удаление локальных кодов, которые имеют ДопБК в ЭТОМ списке" .

DEFINE BUTTON b-save
    LABEL "&Эксп./Вып.":L
    SIZE 10 BY 1
    tooltip "Сохранить список кодов в текстовом файле, файле сканера, EXCEL".

DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B-obj"
     SIZE 3 BY 1.

DEFINE BUTTON b-add
    LABEL "&+Доб. строку":L
    SIZE 14 BY 1
    tooltip "Добавить в список кодов 1 строку".

DEFINE BUTTON b-del
    LABEL "&-Удал. строку":L
    SIZE 14 BY 1
    tooltip "Удалить из списка кодов текущую строки".

DEFINE BUTTON b-rest
    LABEL "&*Остав. строку":L
    SIZE 14 BY 1
    tooltip "Оставить в списке только текущую строку".

DEFINE BUTTON b-exit AUTO-GO
    LABEL "&Выход ":L
    SIZE 10 BY 1
    tooltip "Выход из списка кодов(передача списка другой программе)".

DEFINE BUTTON b-help
    LABEL "Помо&щь":L
    SIZE 9 BY 1
    tooltip "Помощь".

DEFINE BUTTON b-hist
    LABEL "Ис&тория":L
    SIZE 10 BY 1
    tooltip "Последовательность шагов, приведшая к заполнению данного списка".

DEFINE BUTTON b-print
    LABEL "Пе&чать":L
    SIZE 10 BY 1
    tooltip "Печать списка кодов".

DEFINE BUTTON b-lkp
    LABEL "&Просмотр":L
    SIZE 10 BY 1
    tooltip "Просмотр описания текущего товара".

DEFINE BUTTON b-clr
    LABEL "Очи&стить":L
    SIZE 10 BY 1
    tooltip "Удалить из списка все коды (строки)".

DEFINE BUTTON b-macro
    IMAGE-UP FILE "cmp/run.bmp":U
    IMAGE-DOWN FILE "cmp/runi.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/runi.bmp":U
    LABEL '&>':L
    SIZE 4 BY 1.25
    tooltip "Выполнение макроса формирования истории".


DEFINE BUTTON b-record
    IMAGE-UP FILE "cmp/record.bmp":U
    IMAGE-DOWN FILE "cmp/recordi.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/recordi.bmp":U
    LABEL '&o':L
    SIZE 4 BY 1.25
    tooltip "Запись макроса формирования истории".

DEFINE BUTTON b-clear-macro
    IMAGE-UP FILE "cmp/fstop.bmp":U
    IMAGE-DOWN FILE "cmp/fstopi.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/fstopi.bmp":U
    LABEL "&[ ]":L
    SIZE 4 BY 1.25
    tooltip "Удаление макроса формирования истории из памяти".

DEFINE BUTTON b-stop
    IMAGE-UP FILE "cmp/stop.bmp":U
    IMAGE-DOWN FILE "cmp/stopi.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/stopi.bmp":U
    LABEL "&[ ]":L
    SIZE 4 BY 1.25
    tooltip "Конец записи макроса формирования истории".


DEFINE BUTTON b-pause
    IMAGE-UP FILE "cmp/pause.bmp":U
    IMAGE-DOWN FILE "cmp/pausei.bmp":U
    IMAGE-INSENSITIVE FILE "cmp/pausei.bmp":U
    LABEL "&||":L
    SIZE 4 BY 1.25
    tooltip "Сброс макроса формирования истории".

DEFINE BUTTON b-optimize
    LABEL "Оптими&з.":L
    SIZE 10 BY 1
    tooltip "Оптимизация списка".

DEFINE VARIABLE dsp-rs AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
    SIZE 98.5 BY 1
    tooltip "Строка текущего состояния списка"
    FGCOLOR 4
    no-undo.

DEFINE VARIABLE f-tot-lns AS integer FORMAT ">>>>>>>>9":U
      VIEW-AS TEXT
    SIZE 9 BY 0.70
    tooltip "Кол. строк"
    FGCOLOR 4
    no-undo.

DEFINE VARIABLE RS-status AS character
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
    SIZE 32 BY 1 NO-UNDO.

define variable loc-art AS CHAR VIEW-AS fill-in size 14 by 1
    tooltip "Начало артикула для поиска строки"
    fgcolor 12 no-undo.
define variable loc-name AS CHAR VIEW-AS fill-in size 20 by 1
    tooltip "Начало названия товара для поиска строки"
    fgcolor 12 no-undo.
define variable loc-code AS CHAR VIEW-AS fill-in size 20 by 1
    tooltip "Код (бар-код) для поиска строки"
    fgcolor 12 no-undo.
define variable loc-b-str AS CHAR VIEW-AS fill-in size 20 by 1
    tooltip "ДопБК для поиска строки"
    fgcolor 12 no-undo.

define variable a-n-c AS CHAR VIEW-AS RADIO-SET horizontal /* vertical */ RADIO-BUTTONS
"&А","art",
"&Н","name",
"&К","code",
"&ДБК","b-str"
SIZE 18 BY 1
    tooltip "Выбор режима поиска: А - артикул, Н - начало названия, К - код (бар-код), ДБК - ДопБК"
    no-undo.


DEFINE VARIABLE T-all-prt AS LOGICAL INITIAL no
     LABEL "ВСЕ коды призн."
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.

DEFINE VARIABLE T-bc-alt AS LOGICAL INITIAL no
     LABEL "неосновн. (EAN)"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.

DEFINE VARIABLE T-bc-base AS LOGICAL INITIAL no
     LABEL "основн.  (EAN)"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.

DEFINE VARIABLE T-loc-alt AS LOGICAL INITIAL no
     LABEL "неосновн. коды"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.

DEFINE VARIABLE T-loc-base AS LOGICAL INITIAL no
     LABEL "основн. коды"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.

DEFINE VARIABLE T-parts-all AS LOGICAL INITIAL no
     LABEL "на все партии"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.

DEFINE VARIABLE T-parts-not-blank AS LOGICAL INITIAL no
     LABEL "с непуст. N парт."
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.

DEFINE VARIABLE T-parts-ser AS LOGICAL INITIAL no
     LABEL "на сер. товар"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.

DEFINE VARIABLE T-pb-alt AS LOGICAL INITIAL no
     LABEL "ДопБК неосн.ед.изм"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.

DEFINE VARIABLE T-pb-base AS LOGICAL INITIAL no
     LABEL "ДопБК осн.ед.изм"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.

DEFINE VARIABLE T-sc-base AS LOGICAL INITIAL no
     LABEL "весов и топл."
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .79 NO-UNDO.


define variable v-obj-type as character view-as fill-in size  4 by 1 fgcolor 12 no-undo.
define variable v-obj-code as integer   view-as fill-in size  6 by 1 fgcolor 12 no-undo.
define variable v-obj-name as character view-as fill-in size 30 by 1 fgcolor 12 no-undo format "x(30)":U.

DEFINE QUERY BR-option FOR
      temp-list SCROLLING.

DEFINE BUTTON b-cd
    LABEL "По &умолч":L
    SIZE 10 BY 1
    tooltip "Опции кодов установить в соответствии с настройками магазина-передача на кассу".



DEFINE BROWSE BR-option QUERY BR-option
DISPLAY
temp-list.fname format "X(255)" width 60 COLUMN-FONT 2
WITH NO-LABELS SIZE 30 BY 13 separators
tooltip "Условие для выбора кодов, которые будут добавлены / удалены / оставлены в списке"
.

DEFINE QUERY br-list FOR {1} SCROLLING.

DEFINE BROWSE br-list QUERY br-list NO-LOCK DISPLAY
      {1}.gds-code
      {1}.b-code   format ">>>>>>>>9" column-label "Бар-код"
      {1}.b-str    format "X(17)" column-label "ДопБК/лок.ЕАН"
      {1}.bc-on    format "+/" column-label "В!к!л"
      {1}.artic
      {1}.gds-name &if "{1}" = "scnblist" &then format "x(25)"
      {1}.qnty column-label "Количество" format "->>>,>>9.999" &endif
      {1}.f-name
      {1}.unit-base column-label "Осн!Ед!Изм" format "x(3)"
      {1}.bc-unit-cli column-label "Ед!Изм!кода" format "x(3)"
      {1}.bc-cli-base-rate column-label "кратность" format ">>,>>9.999"
      (if {1}.stts = 0 then no else yes) column-label "-" format "-/ "
      {1}.in-code column-label "№ ПН" format  "X(18)" width 16
      {1}.part-code column-label "№ Партии" format  "X(255)" width 10
      {1}.grp-name
      ({1}.prod-type + string ({1}.prod-code, ">>>>>>>>>9") ) column-label "Производитель" format "x(13)"
      &if "{1}" = "scnblist" &then
      enable {1}.qnty
      &endif
      WITH SIZE 68.5 BY 16 separators FONT 2.

{ str/term-prt.i ub.goods }
{ str/asc-bbc.i  ub.goods }


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME {&frame-name}
    dsp-rs  AT ROW 1 COL 1 NO-LABEL
    b-exit  AT ROW 2 COL 1
    b-save  AT ROW 2 COL 11
    b-print AT ROW 2 COL 21
    b-hist  AT ROW 2 COL 31
    b-lkp   AT ROW 2 COL 41
    b-clr   AT ROW 2 COL 51
    b-help  AT ROW 2 COL 61
    b-cd    AT ROW 2 COL 81
    b-add   AT ROW 3 COL 19
    b-del   AT ROW 3 COL 33
    b-rest  AT ROW 3 COL 47
    v-obj-type at row 4 col 2 No-LABEL
    v-obj-code at row 4 col 6 No-LABEL
    b-obj at row 4 col 12
    v-obj-name at row 4 col 15 No-LABEL
    loc-art  AT ROW 4 COL 27 COLON-ALIGNED label "Начало артикула"
    loc-name AT ROW 4 COL 27 COLON-ALIGNED label "Начало названия" format "x(40)"
    loc-code AT ROW 4 COL 27 COLON-ALIGNED label "Бар-код (весь)" format "x(13)"
    loc-b-str AT ROW 4 COL 27 COLON-ALIGNED label "ДопБК" format "x(13)"
    a-n-c    at row 3 col 1 no-label
    T-loc-base AT ROW 3  COL 61
    T-pb-base  AT ROW 3  COL 80
    T-loc-alt  AT ROW 3.75 COL 61
    T-pb-alt   AT ROW 3.75 COL 80
    T-bc-base  AT ROW 4.5  COL 61
    T-sc-base  AT ROW 4.5  COL 80
    T-bc-alt   AT ROW 5.25  COL 61
    T-all-prt  AT ROW 5.25  COL 80
    T-parts-ser AT ROW 6 COL 80
    T-parts-not-blank AT ROW 6.75 COL 80
    T-parts-all AT ROW 7.5 COL 80
    RS-status at row 5 col 2 no-label
    b-macro AT ROW 4.7 col 44
    b-record AT ROW 4.7 col 47
    b-stop   AT ROW 4.7 col 47
    b-clear-macro AT ROW 4.7 col 47
    b-optimize AT ROW 5 COL 34
    f-tot-lns AT ROW 5 col 52 no-label
    br-list  AT ROW 6 COL 1
    br-option AT ROW 8.5 COL 70
    ub.clients.obj-name  at row 22 col 6 colon-aligned label "Пр-ль" fgcolor 4
    ub.gds-prt.node-name at row 22 col 45 colon-aligned label "Шкала" fgcolor 4
    ub.bar-code.b-code   at row 22 col 67 colon-aligned label "Код" format "9999999999" fgcolor 4
    SPACE(0) SKIP(0)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
        SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
        TITLE "СПИСОК  КОДОВ":L
        DEFAULT-BUTTON b-exit.


&scop sel-obj ~
 ~{                       ~
   gbl/uobjsone.i         ~
    parparentproc         ~
    v-cntxt-db-num        ~
    v-cntxt-userid        ~
    v-cntxt-host-code-obj ~
    v-cntxt-obj-type      ~
    v-cntxt-obj-code      ~
    v-user-select         ~
    v-sel-obj-type        ~
    v-sel-obj-code        ~
  ~}                       ~
  if not v-user-select then do: ~
    run UI-on. ~
    return no-apply. ~
  end.

&scop sel-host ~
  /*пока сделаем host для выбранной фирмы only*/  ~
 ~{ gbl/uobjsone.i        ~
    parparentproc         ~
    v-cntxt-db-num        ~
    v-cntxt-userid        ~
    v-cntxt-host-code-obj ~
    v-cntxt-obj-type      ~
    v-cntxt-obj-code      ~
    v-user-select         ~
    v-sel-obj-type        ~
    v-sel-obj-code        ~
  ~}                       ~
  if not v-user-select then do: ~
    run UI-on in this-procedure . ~
    return error.  ~
  end.  ~
  ~{ gbl/hostcode.i v-sel-obj-type v-sel-obj-code v-host-code no-error ~}  ~
  if error-status:error then do:  run UI-on in this-procedure.   return error.  end.

/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN
  b-save:POPUP-MENU IN FRAME {&frame-name} = MENU m-save:HANDLE
  FRAME {&frame-name}:SCROLLABLE = FALSE
  b-save:MENU-MOUSE = 1
  b-optimize:POPUP-MENU IN FRAME {&frame-name} = MENU m-optimize:HANDLE
  b-optimize:MENU-MOUSE = 1
  .


/* ************************  Control Triggers  ************************ */

on
  return of
  &if "{1}" = "scnblist" &then
  {1}.qnty in browse br-list,
  &endif
  br-list in frame {&frame-name} do:

  /* убиваем return, чтоб не вылетала из списка */
  apply "choose" to b-lkp in frame {&frame-name}.
  return no-apply.
end.

on choose of b-obj in frame {&FRAME-NAME} do:
  run proc-b-obj in this-procedure ( input "change":U ).
end.

ON CHOOSE OF MENU-ITEM m-cd /* передача на кассу */ DO:
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
run proc-cd in this-procedure no-error.
end.

ON CHOOSE OF MENU-ITEM m-title-save /* ИМЯ СПИСКА  */ DO:
define variable v-value as character no-undo .
  run gbl/d-prompt.w (
      'title=':u + "Введите ИМЯ СПИСКА КОДОВ" + '\':u
    + 'format=' + "X(60)" + '\':u
    + 'type=' + {&type-char} + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=60\':u
    + 'fillin_height=1\':u
    + 'max-chars=60\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output v-value
    ).
if return-value = 'false':u then return NO-apply.
run create-{1}-hist in this-procedure (input 'title'
                                     , input-output v-seq
                                     , input 0
                                     , input 'N':U
                                     , input v-value
                                     , input tot-lns
                                     , input "title"
                                     , input '':U
                                     , input '':U
                                     , input '':U
                                     , input ?
                                     ).
assign
frame {&frame-name}:title = substitute("СПИСОК  КОДОВ &1", v-value).
END.

ON CHOOSE OF MENU-ITEM m-gds-save /* Файл списка товаров */ DO:
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
  assign
    f-gds-name = "default.gds"
    glog = yes
    .

  system-dialog get-file f-gds-name
    filters "Списки товаров *.gds" "*.gds"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "gds".
  if not glog then do:
    apply "entry" to br-list in frame {&frame-name}.
    return no-apply.
  end.
  output to value (f-gds-name).
  for each {1}
  break by {1}.gds-code
  :
    if first-of({1}.gds-code) then
    export {1}.prod-type
          {1}.prod-code
          {1}.artic
          .
  end.
  output close.
END.

ON CHOOSE OF MENU-ITEM m-bb-save /* Файл списка кодов */ DO:
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
  assign
    f-gds-name = "default.bb"
    glog = yes
    .

  system-dialog get-file f-gds-name
    filters "Списки кодов *.bb" "*.bb"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "bb".
  if not glog then do:
    apply "entry" to br-list in frame {&frame-name}.
    return no-apply.
  end.
  output to value (f-gds-name).
  for each {1}
  break by {1}.gds-code
  :
    export
    {1}.b-code
    {1}.b-str
    {1}.prod-type
    {1}.prod-code
    {1}.artic
    .
  end.
  output close.
END.




ON CHOOSE OF MENU-ITEM m-scn-save /* Файл сканера */ DO:
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
run proc-scn-tsd in this-procedure no-error .
if error-status:error then return no-apply.

END.

ON CHOOSE OF MENU-ITEM m-macros-save /* Файл макрос */ DO:
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
run proc-macros in this-procedure no-error .
if error-status:error then return no-apply.
END.

ON CHOOSE OF MENU-ITEM m-xls-save /* EXCEL */ DO:
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
do on stop  undo, return no-apply
  on error undo, return no-apply
  on quit  undo, return no-apply
:
&if "{1}" = "scnblist":U &then
  run str/scnlbxls.p (
                 input parparentproc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                )
    no-error.
&else
  run str/gdslbxls.p (
                 input parparentproc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                )
                 no-error.
&endif
  run waitfram-hide in this-procedure .
end.
END.

ON CHOOSE OF MENU-ITEM m-delnprod-bc /* Удаление локальных кодов, которые имеют ДопБК в ЭТОМ списке*/
DO:
    optimize-option = "delnprod-bc":U.
    optimize-label = self:label.
    dsp-rs = menu-ITEM m-delnprod-bc:label in menu m-optimize.
    apply "choose" to b-optimize in frame {&frame-name}.
END.

ON CHOOSE OF MENU-ITEM m-repnprod-bc /* Замена локальных кодов на ДопБК (если они есть в системе) */
DO:
    optimize-option = "repnprod-bc":U.
    optimize-label = self:label.
    dsp-rs = menu-ITEM m-repnprod-bc:label in menu m-optimize.
    apply "choose" to b-optimize in frame {&frame-name}.
END.

&global-define store-type p-curr-obj-type
&global-define store-code p-curr-obj-code

{ str/sch-line.i {1} br-list }
{&disp-hot-fields}
end.

ON CHOOSE OF b-print IN FRAME {&frame-name} DO:
&if "{1}" = "scnblist" &then
run rep/pri-lst.w (
               input parparentproc
             , input p-curr-obj-type
             , input p-curr-obj-code
             , input "LIST"
             , input "bb-list").
&else
run rep/pri-lst.w (
               input parparentproc
             , input p-curr-obj-type
             , input p-curr-obj-code
             , input "ALL"
             , input "bb-list").
&endif
apply "entry" to br-list in frame {&frame-name}.
END.

ON CHOOSE OF b-lkp IN FRAME {&frame-name} DO:
if not available {1} then do:
  message "Неправильно выбран товар."
          view-as alert-box error.
  return no-apply.
end.
find ub.goods where {1}.artic = ub.goods.artic
            and {1}.prod-type = ub.goods.prod-type
            and {1}.prod-code = ub.goods.prod-code no-lock.
run str/showgds.p ( input parparentproc
                   ,input this-procedure:handle /*p-call-handle*/
                   ,input  goods.gds-code
                   ,input {&lookup}).
apply "entry" to br-list in frame {&frame-name}.
END.

ON CHOOSE OF b-hist IN FRAME {&frame-name} DO:
define buffer buf_{1}-hist for {1}-hist.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
find first buf_{1}-hist no-lock where buf_{1}-hist.id = 0 no-error .
PUT  STREAM PrnLibStream unformatted
SPACE(25) "История создания списка кодов "
(if available buf_{1}-hist
then buf_{1}-hist.des
else "БЕЗЫМЯННЫЙ") skip(0)
space(25) cur-time-print() skip(1)
.
put stream PrnLibStream unformatted
string("№", "X(9)") {&space-char}
string("Действие", "X(9)") {&space-char}
string("записей", "X(10)") {&space-char}
string(" = итого", "X(12)") {&space-char}
string("Множество", "X(155)")
skip(0)
fill('-':U, 9) {&space-char}
fill('-':U, 9) {&space-char}
fill('-':U, 9) {&space-char}
fill('-':U, 12) {&space-char}
fill('-':U, 155)
skip(0)
.
for each buf_{1}-hist where buf_{1}-hist.id > 0
by buf_{1}-hist.id
:
  put stream PrnLibStream unformatted
  (if buf_{1}-hist.line = 0
   then string(buf_{1}-hist.id, ">>>>>>>>9")
   else fill({&space-char} , 9)
  )  {&space-char}
  (if buf_{1}-hist.item_ <> '':U
   then string(buf_{1}-hist.hist-mode, "X(8)")
   else fill( {&space-char}, 8)) {&space-char}
  string(buf_{1}-hist.num-add, "->>>>>>>>9") {&space-char} {&space-char} {&space-char} {&space-char}
  string(buf_{1}-hist.num-recs, ">>>>>>>>9")  {&space-char}
  string(buf_{1}-hist.des, "X(155)") skip.
end.
output stream prnlibstream close.
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).

  apply "entry" to br-list in frame {&frame-name}.
END.

ON CHOOSE OF b-clr IN FRAME {&frame-name} /* Очистка */ DO:
define variable glog as logical no-undo .
define buffer buf-{1}-hist for {1}-hist.
glog = no.
message "Удаление всех строк списка. Вы уверены ?"
        view-as alert-box question buttons OK-Cancel update glog.
if not glog then return no-apply.
if session:set-wait-state( "COMPILER" )  then .
for each {1}:
  delete {1}.
end.
if session:set-wait-state( "" )  then .
tot-lns = 0.
v-seq = 1.
for each buf-{1}-hist:
  delete buf-{1}-hist.
end.
run create-{1}-hist in this-procedure (input {&add-def}
                                     , input-output v-seq
                                     , input 0
                                     , input '0':U
                                     , input "# Список кодов очищен."
                                     , input 0
                                     , input "clear"
                                     , input '':U
                                     , input '':U
                                     , input '':U
                                     , input ?
                                     ).
display
tot-lns @ f-tot-lns
? @ ub.clients.obj-name
? @ ub.gds-prt.node-name
? @ ub.bar-code.b-code with frame {&frame-name}.
run UI-on.
END.

ON VALUE-CHANGED OF RS-Status IN FRAME {&frame-name} DO:
  assign
  RS-status.
END.

ON CHOOSE OF b-cd IN FRAME {&frame-name} DO:
run proc-b-cd in this-procedure  ( input no) no-error.
if error-status:error then return no-apply.
apply "entry" to br-list in frame {&frame-name}.
END.

ON CHOOSE OF b-optimize IN FRAME {&frame-name} DO:
if optimize-option = "" then do:
  run gbl/pop-up.p (self:handle, no) no-error.
end.
if optimize-option = "" then do:
  return no-apply.
end.
run create-{1}-hist in this-procedure(input {&add-def}
                                    , input-output v-seq
                                    , input 0
                                    , input '~~':U
                                    , input substitute('Оптимизация списка &1 - &2'
                                                  , stat-line(rs-status)
                                                  , optimize-label)
                                    , input tot-lns
                                    , input 'optimize'
                                    , input rs-status
                                    , input optimize-option
                                    , input '':U
                                    , input ?
                                    ).
run rs-do in this-procedure ( input no, input no, input 'optimize', input rs-status, input {&add-def}, input (v-seq - 1)) no-error .
if error-status:error then do:
  optimize-option = "".
  optimize-label = '':U.
  return no-apply.
end.
apply "entry" to br-list in frame {&frame-name}.
END.




&if "{1}" = "scnblist" &then
ON RETURN of {1}.qnty in browse br-list do:
  APPLY "LEAVE" to self.
END.
&endif

{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-del }

/* ***************************  Main Block  *************************** */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/diasize.i &browse-name="br-list" }
{ gbl/app_help.i &disable_diasize=true }
run diasize_init in this-procedure .


{ str/an-listp.i {1} bb-list bbm }

define variable v-ok as logical   no-undo .
assign
  v-ok = br-list :set-repositioned-row(5, 'conditional':u)
.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }

  { str/sclspref.i varscales-pref varpgscales-pref }
  { gbl/conf-rd.i
  "'is-tsd'"
  0
  "'':U"
  0
  "''"
  "''"
  "''"
  no
  conf-par
  par-type
  no-error
  }
  assign
  is-tsd = (if conf-par = "yes" then yes else no)
  .
  { gbl/getcntxt.i get }
  if p-curr-obj-type = '':U
  and p-curr-obj-code = 0 then do:
  { gbl/uobjsone.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
      v-sel-obj-type
      v-sel-obj-code
    }
    if v-user-select then do: ~
      FIND FIRST buf_user-obj no-lock where
              buf_user-obj.obj-type = v-sel-obj-type
          and buf_user-obj.obj-code = v-sel-obj-code  No-ERROR.
      if not avail buf_user-obj then return no-apply.
      find first buf_clients no-lock where
                buf_clients.obj-type = buf_user-obj.obj-type
            and buf_clients.obj-code = buf_user-obj.obj-code no-error.
      if not available buf_clients then return error.
      assign
      p-curr-obj-type = buf_clients.obj-type
      p-curr-obj-code = buf_clients.obj-code
      v-host-code = buf_clients.host-code
      v-no-obj = yes
      .
    end.
    else do:
      message
      "Текущий объект не может быть установлен" skip
      view-as alert-box error .
      undo, return error.
    end.
  end.
  if not (p-curr-obj-type = '':U
          and
          p-curr-obj-code = 0) then do:
    find first buf_clients no-lock
        where buf_clients.obj-type = p-curr-obj-type
        AND    buf_clients.obj-code = p-curr-obj-code no-error.
    if not available buf_clients
    or not (buf_clients.obj-type = {&shop}
      or
      buf_clients.obj-type = {&stock}
      )
    then do:
      assign
      p-curr-obj-type = '':U
      p-curr-obj-code = 0
      .
      message
      vss-workfile vss-revision vss-description skip
      "Неверно заданы входные параметры p-curr-obj-type и/или p-curr-obj-code"
      p-curr-obj-type p-curr-obj-code
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.


  assign
  line-rec = ?
  .
  assign
  br-option:column-scrolling in frame {&frame-name}  = no
  RS-status:radio-buttons = "Текущие&+" + {&comma-char} + {&current} + {&comma-char} +
                            "Все!" + {&comma-char} + {&all} + {&comma-char} +
                            "Неактивные-" + {&comma-char} + {&deleted}
  RS-status = {&current}
  .
  if v-no-obj
  or v-cntxt-level <>  {&cntxt-object} then do:
    if v-obj-name = "":U then do:
      run proc-b-obj in this-procedure ( input "":U ).
    end.
    display
      b-obj
      v-obj-type
      v-obj-code
      v-obj-name
    with frame {&FRAME-NAME} .
    enable
      b-obj
    with frame {&FRAME-NAME} .
  end.
  else do:
    assign
    v-obj-type  = p-curr-obj-type
    v-obj-code  = p-curr-obj-code
    .

    if v-obj-type = {&shop} then do:
      find first ub.shop no-lock where
                ub.shop.obj-code = v-obj-code.
      find first sysconf no-lock where
                sysconf.host-code = shop.host-code .
      assign
      v-is-restaurant = ub.shop.is-catering
      v-doc-prt = ub.shop.doc-prt.
      .
    end.
    else do:
      find first ub.store no-lock where
                ub.store.obj-code = p-curr-obj-code.
      find first sysconf no-lock where
                sysconf.host-code = store.host-code .
      v-doc-prt = ub.store.doc-prt.
    end.

    /*заполним temp-list*/
    run proc-fill-temp-list in this-procedure .
    for each temp-shop:
      delete temp-shop.
    end.
    create temp-shop.
    run proc-b-cd in this-procedure  ( input yes).
  end.

  run UI-on.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-list.
END.
HIDE FRAME {&frame-name}.

/* **********************  Internal Procedures  *********************** */

PROCEDURE UI-on:
define variable v-recid0 as recid no-undo.
define variable v-start as logical no-undo .
define buffer buf_temp-list for temp-list.
define buffer buf_{1}-hist for {1}-hist.
{1}.part-code:resizable in browse br-list = yes.
{1}.in-code:resizable in browse br-list = yes.
if v-cntxt-level <> {&cntxt-object}
or v-cntxt-obj-type <> {&shop} then do:
  assign
  MENU-ITEM m-cd:sensitive in menu m-save = no.
end.
  find first buf_{1}-hist where buf_{1}-hist.id = 0 no-error.
  if available buf_{1}-hist then
  assign
  frame {&frame-name}:title = substitute("СПИСОК  КОДОВ &1",  string(buf_{1}-hist.des, "X(60)"))
  .

  if tot-lns = ? then do:
    /* первоначальное заполнение истории списка при входе в него */
    v-start = yes.
    for each l-{1} :
      accumulate l-{1}.artic (count).
    end.
    tot-lns = (accum count l-{1}.artic).
    if tot-lns > 0 then do:
      find last  buf_{1}-hist no-error .
      if available buf_{1}-hist and buf_{1}-hist.id = 1 and v-start then delete buf_{1}-hist.
      v-seq = (if available buf_{1}-hist then buf_{1}-hist.id else 0)  + 1.
      run create-{1}-hist in this-procedure (input {&add-def}
                                           , input-output v-seq
                                           , input 0
                                           , input 'S':U
                                           , input substitute("# Исходный список: &1 строк", tot-lns)
                                           , input tot-lns
                                           , input "start":U
                                           , input '':U
                                           , input '':U
                                           , input '':U
                                           , input ?
                                           ).
    end.
    else do:
      line-mode = {&add-def}.
      for each buf_{1}-hist:
        delete buf_{1}-hist.
      end.
      v-seq = 1.
      run create-{1}-hist in this-procedure (input {&add-def}
                                           , input-output v-seq
                                           , input 0
                                           , input '':U
                                           , input "# Исходный список кодов пуст."
                                           , input tot-lns
                                           , input 'start':U
                                           , input '':U
                                           , input '':U
                                           , input '':U
                                           , input ?
                                           ).
    end.
  end.
  hide loc-art in frame {&frame-name} loc-name loc-code loc-b-str in frame {&frame-name}.
  assign
    loc-art = ""
    RS-list-method = "single"
    dsp-rs = "Всего строк в списке кодов : " + string (tot-lns).
  find first buf_temp-list no-lock where
             buf_temp-list.fvalue = rs-list-method.
  assign
  v-recid0 = recid(buf_temp-list).
  {&OPEN-BR-option}
  DISPLAY br-option dsp-rs RS-Status WITH FRAME {&frame-name}.
  ENABLE
  b-exit b-add b-hist b-help br-option br-list RS-Status b-cd
  T-loc-base
  T-loc-alt
  &if "{&ean-option}" <> "no" &then
  T-bc-base
  T-bc-alt
  &endif
  T-all-prt
  &if "{&parts-option}" <> "no" &then
  T-parts-ser
  T-parts-not-blank
  T-parts-all
  &endif
  &if "{&pbc-option}" <> "no" &then
  T-pb-base
  T-pb-alt
  T-sc-base
  &Endif
  WITH FRAME {&frame-name}.
  &if "{1}" <> "scnblist" &then
  if is-tsd = no then do:
    menu-item m-scn-save:sensitive in menu m-save = no.
  end.
  &endif
  reposition br-option to recid v-recid0.
  if tot-lns > 0 then
    ENABLE b-print b-rest b-save b-del b-lkp b-clr a-n-c b-optimize WITH FRAME {&frame-name}.
  else do:
    DISABLE b-print b-rest b-save b-del b-lkp b-clr a-n-c b-optimize WITH FRAME {&frame-name}.
  end.
  {&open-br}
 if v-seq > 1 then
  find last buf_{1}-hist no-lock where
            buf_{1}-hist.id = (v-seq - 1)
       and  buf_{1}-hist.line = 0 no-error .
  DISPLAY br-option
  (if available buf_{1}-hist
  then buf_{1}-hist.des
  else '') @ dsp-rs
  RS-Status WITH FRAME {&frame-name}.
  ENABLE
  b-macro  when v-start
  b-record when v-start
  b-exit b-add b-hist b-help br-option br-list RS-Status WITH FRAME {&frame-name}.
  if v-start then do:
    hide
    b-stop
    b-clear-macro
    in frame {&frame-name}.
  end.
  v-start = no.
  if line-rec <> ? then
    reposition br-list to recid line-rec no-error.
  /* Отключено, т.к. после reposition в updatable browse последняя строка выводится повторно на месте 1-й.
    Включается только в старом варианте списка */
  &if "{1}" <> "scnblist" &then
  apply "entry" to br-list in frame {&frame-name}.
  &endif
  /* Отключено, т.к. после reposition в updatable browse последняя строка выводится повторно на месте 1-й.
    Вместо этого скопирован следующий кусок кода из триггера на iteration-changed.
    apply "iteration-changed" to br-list in frame {&frame-name}. */
  {&disp-hot-fields}
END PROCEDURE.

{ cmp/ex-bbc.i {1} {&frame-name} }

PROCEDURE rs-do :
define input parameter p-from-macro as logical no-undo .
define input parameter p-step as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .

/* обработка нажатия батона в зависимости от rs */
define variable v-rowid   as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable glog as logical no-undo .
define buffer buf_{1}-hist for {1}-hist.

define variable another-price like ub.price-list.price-sale no-undo.
define variable scan-qnty as dec no-undo.                /* количество, введенное при сканировании */
define variable bc-qnty as dec no-undo.                  /* коэффициент (вес) из бар-кода */
define variable var-root-code like ub.gds-prt.node-code no-undo .
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define variable v-value-integer as integer   no-undo .
define variable v-db-num as integer no-undo .
define variable l-prod-bc-weight as logical no-undo .
define variable l-prod-bc-pgweight as logical no-undo .
define variable l-prod-bc-glob as logical no-undo .

define variable v-is-weight as logical no-undo .
define variable IBM-good-code as character no-undo .
define variable bar_code as character no-undo .
define variable v-prev-b-code as integer no-undo .
define variable v-b-code as integer   no-undo .
define variable v-from-date as date no-undo .
define variable v-to-date as date no-undo .
define variable v-from-date-str as character no-undo .
define variable v-to-date-str as character no-undo .
define variable v-using as character no-undo .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_parts for ub.parts.
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_parts-obj-attr for ub.parts-obj-attr.
define buffer buf_code-range for ub.code-range.
define buffer buf_prod-bc-db for ub.prod-bc-db.
define buffer buf_gds-obj-attr for ub.gds-obj-attr.
define buffer buf_scales-gds for ub.scales-gds.

do
on error undo, return error return-value
:

if p-from-macro then do:
end.
else do:
  assign
  frame {&frame-name}
  T-all-prt
  &if "{&ean-option}" <> "no" &then
  T-bc-alt
  T-bc-base
  &endif
  T-loc-alt
  T-loc-base
  &if "{&parts-option}" <> "no" &then
  T-parts-all
  T-parts-not-blank
  T-parts-ser
  &endif
  &if "{&pbc-option}" <> "no" &then
  T-pb-alt
  T-pb-base
  T-sc-base
  &endif
  .
  if (
  T-all-prt or
  T-bc-alt  or
  T-bc-base or
  T-loc-alt or
  T-loc-base  or
  T-parts-all  or
  T-parts-not-blank or
  T-parts-ser or
  T-pb-alt    or
  T-pb-base   or
  T-sc-base) = no then do:
    message
    "Не выбран ни один тип кодов!"
    view-as alert-box error .
    undo, return error .
  end.

  assign
  temp-shop.obj-code = p-curr-obj-code
  temp-shop.all-prt = T-all-prt
  temp-shop.cd-bc-alt = T-bc-alt
  temp-shop.cd-bc-base = T-bc-base
  temp-shop.cd-loc-alt = T-loc-alt
  temp-shop.cd-loc-base = T-loc-base
  temp-shop.cd-parts-all = T-parts-all
  temp-shop.cd-parts-not-blank = T-parts-not-blank
  temp-shop.cd-parts-ser = T-parts-ser
  temp-shop.cd-pb-alt = T-pb-alt
  temp-shop.cd-pb-base = T-pb-base
  temp-shop.cd-sc-base = T-sc-base
  .
end.
assign
lns-cnt = 0
lns-ignore = 0
v-num-add  = 0
v-num-ignored = 0
tot-lns = (if line-mode = {&leave} then 0 else tot-lns)
.

run write-hist(p-from-macro, rs-list-method, rs-status, line-mode, buffer ub.goods).

if session:set-wait-state( "COMPILER" )  then .
dsp-rs:fgcolor in frame {&frame-name} = 12.
case rs-list-method:
  when "optimize"  then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    run proc-b-optimize(input p-from-macro
                      , input rs-list-method
                      , input rs-status
                      , input buf_{1}-hist.item_
                      ) no-error .
    {&assign-nums}.
  end.
  when "all" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    if p-from-macro then run restore-codes in this-procedure (input buf_{1}-hist.item_, p-curr-obj-type, p-curr-obj-code).
    for each goods no-lock:
      {&NEW-GOOD}
      run process-one-good in this-procedure (input rs-list-method, input rs-status, input line-mode, buffer goods) no-error .
    end.
    {&assign-nums}.
  end.
  when "goods" then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id:
      if buf_{1}-hist.line = 0
      and p-from-macro then run restore-codes in this-procedure (input buf_{1}-hist.item_, p-curr-obj-type, p-curr-obj-code).
      if buf_{1}-hist.line <> 0 then do:
        {&get-rowid} next.
        {&NEW-GOOD}
        find goods where rowid (goods) = v-rowid no-lock.
        run process-one-good in this-procedure (input rs-list-method, input rs-status, input line-mode ,buffer goods) no-error .
        {&assign-nums}.
      end.
    end. /*for each*/
  end. /*when goods*/
  when "goods-b-code"
  or
  when "goods-b-code-ean"
  then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid} next.
      find first buf_bar-code no-lock where
                rowid(buf_bar-code) = v-rowid no-error.
      if available buf_bar-code then do:
        run get-prt-and-unit in this-procedure (
                                                input goods.prt-root
                                                ,input goods.unit-base
                                                ,output l-empty-scale
                                                ) .
        if rs-list-method = "goods-b-code":U then
        run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input "":U, input no, buffer buf_bar-code, buffer buf_prod-bc).
        if rs-list-method = "goods-b-code-ean":U then do:
          RUN gen-bc( input buf_bar-code.b-code, output bar_code ).
          IBM-good-code  = trim( bar_code ) .
          run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input IBM-good-code, input yes, buffer buf_bar-code, buffer buf_prod-bc).
        end.
        {&assign-nums}.
      end.
    end. /*for each*/
  end. /*when goods-b-code*/
  when "goods-b-str" then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid} next.
      find first buf_prod-bc no-lock where
              rowid(buf_prod-bc) = v-rowid no-error.
      if available buf_prod-bc then do:
        find first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_prod-bc.b-code no-error.
        if available buf_prod-bc then do:
          run get-prt-and-unit in this-procedure (
                                                  input goods.prt-root
                                                  ,input goods.unit-base
                                                  ,output l-empty-scale
                                                  ) .
          run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,  input l-empty-scale, input "":U, input no, buffer buf_bar-code, buffer buf_prod-bc).
        end.
      end.
    end.
  end.
  when "gds-list"  then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id:
      if buf_{1}-hist.line = 0
      and p-from-macro then run restore-codes in this-procedure (input buf_{1}-hist.item_, p-curr-obj-type, p-curr-obj-code).
      if buf_{1}-hist.line <> 0 then do:
        {&get-rowid} next.
        find first goods no-lock where rowid(goods) = v-rowid.
        {&NEW-GOOD}
        run process-one-good in this-procedure (input rs-list-method, input rs-status, input line-mode,buffer goods) no-error .
        {&assign-nums}.
      end.
    end.
  end. /*when gds-list*/
  when "file-gds"
  or
  when "scaner"
  then do:
    run proc-file-list-methods in this-procedure(input p-from-macro, input rs-list-method, input rs-status, input line-mode, input p-id). .
  end.
  when "last-check":U then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U .
    assign
    v-curr-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
    v-curr-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
    v-chk-date-chr = entry(3, buf_{1}-hist.item_, {&delim-key})
    v-chk-date = date(integer(substring(v-chk-date-chr, 4, 2)),
                  integer(substring(v-chk-date-chr, 1, 2)),
                  integer(substring(v-chk-date-chr, 7, 4)))
    no-error
    .
    if error-status:error then do: end. else do:
      for each ub.chk-doc no-lock where
              ub.chk-doc.obj-type = v-curr-obj-type
          AND ub.chk-doc.obj-code = v-curr-obj-code
          and ub.chk-doc.chk-date <= v-chk-date,
          each ub.chk-gds no-lock where
              ub.chk-gds.doc-code = ub.chk-doc.doc-code:
        { str/bc-rcnz.i
          parparentproc
          "entry(1, chk-gds.src-code, ~{&delim-par~})"
          ?
          v-curr-obj-type
          v-curr-obj-code
          yes
          no
          varscales-pref
          varpgscales-pref
          varresult
          vartype-bc
          varweight
          ub.bar-code
          ub.prod-bc
          ub.place
          no-error
        }
        if not available ub.bar-code then next.
        {&NEW-GOOD}
        find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK no-error.
        if available goods then do:
          run get-prt-and-unit in this-procedure (
                                                  input ub.goods.prt-root
                                                  ,input ub.goods.unit-base
                                                  ,output l-empty-scale
                                                  ) .
          run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input "":U, input (not available prod-bc), buffer bar-code, buffer prod-bc).
          /* количество пишем, если есть запись (не удаление и не попытка добавить удаленный товар),
            если это не запись, оставшаяся от предыдущего цикла */
        end.
      end. /*for each chk-doc.*/
      {&assign-nums}.
    end.
  end.
  when "prod-bc-off" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    if p-from-macro then run restore-codes in this-procedure (input buf_{1}-hist.item_, p-curr-obj-type, p-curr-obj-code).
    for each ub.prod-bc no-lock
    by ub.prod-bc.b-code
    :
      if ub.prod-bc.bc-on = no then do:
        if ub.prod-bc.b-code <> v-prev-b-code then do:
          find first ub.bar-code no-lock where ub.bar-code.b-code = ub.prod-bc.b-code no-error.
          {&NEW-GOOD}
          if available ub.bar-code then do:
            find first ub.goods no-lock where ub.goods.gds-code = ub.bar-code.gds-code no-error.
          end.
        end.
        if available ub.bar-code
        and available ub.goods then do:
          run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input ?, input ub.prod-bc.b-str, input no, buffer bar-code, buffer prod-bc).
          {&assign-nums}.
          v-prev-b-code = ub.prod-bc.b-code.
        end.
      end. /*if prod-bc.bc-on = no then do:*/
    end. /*for each prod-bc no-lock*/
  end. /*when prod-bc-off*/
  when "cd-codes":U then do:
    for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      assign
      v-curr-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-curr-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
      v-pos-type = entry(3, buf_{1}-hist.item_, {&delim-key})
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-curr-obj-type
              AND buf_user-obj.obj-code = v-curr-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          CASE v-pos-type:
            when {&cd-type-r-keeper} then do:
              for each buf_cd-plu where
                      buf_cd-plu.obj-type = {&shop}
                  and buf_cd-plu.obj-code = buf_user-obj.obj-code
                  and buf_cd-plu.pos-type = {&cd-type-r-keeper}:
                release prod-bc.
                find first ub.bar-code no-lock where
                          ub.bar-code.b-code = buf_cd-plu.b-code no-error.
                if not available ub.bar-code then next.
                if available goods then do:
                  run get-prt-and-unit in this-procedure (
                                                                input ub.goods.prt-root
                                                                ,input ub.goods.unit-base
                                                                ,output l-empty-scale
                                                      ) .
                  run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,input no, input "":U, input no, buffer bar-code, buffer prod-bc).
                end.
              end. /* for each buf_cd-plu no-lock where*/
            end.
          end case.
        end.
      end.
      {&assign-nums}.
    end. /*for each bf_hist*/
  end.
  when "parts-cashparts":U
  or
  when "parts-ean-cashparts":U
    then do:
      for each buf_{1}-hist where
              buf_{1}-hist.id = p-id
          and  buf_{1}-hist.item_ <> '':U:
        assign
        v-curr-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
        v-curr-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
        no-error
        .
        if error-status:error then do: end. else do:
          find first buf_user-obj no-lock where
                    buf_user-obj.obj-type = v-curr-obj-type
                AND buf_user-obj.obj-code = v-curr-obj-code
                AND buf_user-obj.db-num = v-cntxt-db-num
                AND buf_user-obj.user-id = v-cntxt-userid
                no-error .

          if available buf_user-obj then do:
            for each buf_gds-obj no-lock where
                    buf_gds-obj.obj-type = v-curr-obj-type
                and buf_gds-obj.obj-code = v-curr-obj-code,
                  each buf_parts no-lock where
                    buf_parts.artic = buf_gds-obj.artic
                 and buf_parts.prod-type = buf_gds-obj.prod-type
                 and buf_parts.prod-code = buf_gds-obj.prod-code
                 and buf_parts.obj-type = v-curr-obj-type
                  and buf_parts.obj-code = v-curr-obj-code
                  and buf_parts.out-code  = {&free-code}
                  and buf_parts.status_   = false:
                if buf_gds-obj.cash-parts = false then next.
                v-b-code = 0.
                { gbl/partbcod.i
                  buf_parts
                  v-b-code
                  no-error
                }

               if v-b-code > 0 then do:
                find first ub.goods no-lock where
                        ub.goods.gds-code = buf_gds-obj.gds-code no-error.
                find first buf_bar-code no-lock where
                          buf_bar-code.b-code = v-b-code no-error.
                if available ub.goods
                and available buf_bar-code
                then do:
                  run get-prt-and-unit in this-procedure (
                                                                input goods.prt-root
                                                                ,input goods.unit-base
                                                                ,output l-empty-scale
                                                      ) .

                  if rs-list-method = "parts-cashparts" then do:
                    run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,input no, input "":U, input no, buffer buf_bar-code, buffer prod-bc).
                  end.
                  if rs-list-method = "parts-ean-cashparts" then do:
                    RUN gen-bc( input buf_bar-code.b-code, output bar_code ).
                    IBM-good-code  = trim( bar_code ) .
                    run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input IBM-good-code, input yes, buffer buf_bar-code, buffer buf_prod-bc).
                  end.
                end. /*if available ub.goods then do:*/
              end. /*if v-b-code > 0 then do:*/
            end. /*            for each buf_gds-obj no-lock where*/
          end. /*if available buf_user-obj then do:*/
        end.
        {&assign-nums}.
      end. /*for each bf_hist*/
    end. /*when "parts-cahsparts":U then do:*/
  when "parts-last-date":U
  or
  when "parts-ean-last-date":U
  then do:
    for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      assign
      v-curr-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-curr-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
      v-value-integer = integer(entry(3, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-curr-obj-type
              AND buf_user-obj.obj-code = v-curr-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each buf_parts no-lock where
                  buf_parts.obj-type = v-curr-obj-type
                and buf_parts.obj-code = v-curr-obj-code
                and buf_parts.out-code  = {&free-code}
                and buf_parts.status_   = false:
            if buf_parts.last-date <> ?
            and (buf_parts.last-date - today) < v-value-integer then do:
              v-b-code = 0.
              { gbl/partbcod.i
                buf_parts
                v-b-code
                no-error
              }
              if v-b-code > 0 then do:
                find first buf_bar-code no-lock where
                          buf_bar-code.b-code = v-b-code no-error.
                if available buf_bar-code then do:
                  find first ub.goods no-lock where
                            ub.goods.gds-code = buf_bar-code.gds-code no-error.
                  if available ub.goods then do:
                    run get-prt-and-unit in this-procedure (
                                                                  input goods.prt-root
                                                                  ,input goods.unit-base
                                                                  ,output l-empty-scale
                                                        ) .
                    if rs-list-method = "parts-last-date" then do:
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,input no, input "":U, input no, buffer buf_bar-code, buffer prod-bc).
                    end.
                    if rs-list-method = "parts-ean-last-date" then do:
                      RUN gen-bc( input buf_bar-code.b-code, output bar_code ).
                      IBM-good-code  = trim( bar_code ) .
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input IBM-good-code, input yes, buffer buf_bar-code, buffer buf_prod-bc).
                    end.
                  end.
                end.
              end.
            end. /*      if buf_parts.last-date - today < vvalue-int then do:*/
          end. /*for each buf_parts*/
        end. /*if available buf_user-obj then do:*/
      end.
      {&assign-nums}.
    end. /*for each bf_hist*/
  end. /*when "parts-last-date":U then do:*/
  when "parts-rsrv-last-date":U
  or
  when "parts-ean-rsrv-last-date":U
  then do:
    for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      assign
      v-curr-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-curr-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
      v-value-integer = integer(entry(3, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-curr-obj-type
              AND buf_user-obj.obj-code = v-curr-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each buf_parts no-lock where
                  buf_parts.obj-type = v-curr-obj-type
                and buf_parts.obj-code = v-curr-obj-code
                and buf_parts.rsrv-free = true
                and buf_parts.status_   = false
                and buf_parts.out-code  <> {&free-code}
                :
            if buf_parts.last-date <> ?
            and (buf_parts.last-date - today) < v-value-integer then do:
              v-b-code = 0.
              { gbl/partbcod.i
                buf_parts
                v-b-code
                no-error
              }
              if v-b-code > 0 then do:
                find first buf_bar-code no-lock where
                          buf_bar-code.b-code = v-b-code no-error.
                if available buf_bar-code then do:
                  find first ub.goods no-lock where
                            ub.goods.gds-code = buf_bar-code.gds-code no-error.
                  if available ub.goods then do:
                    run get-prt-and-unit in this-procedure (
                                                                  input goods.prt-root
                                                                  ,input goods.unit-base
                                                                  ,output l-empty-scale
                                                        ) .
                    if rs-list-method = "parts-rsrv-last-date" then do:
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,input no, input "":U, input no, buffer buf_bar-code, buffer prod-bc).
                    end.
                    if rs-list-method = "parts-ean-rsrv-last-date" then do:
                      RUN gen-bc( input buf_bar-code.b-code, output bar_code ).
                      IBM-good-code  = trim( bar_code ) .
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input IBM-good-code, input yes, buffer buf_bar-code, buffer buf_prod-bc).
                    end.
                  end.
                end.
              end.
            end. /*      if buf_parts.last-date - today < vvalue-int then do:*/
          end. /*for each buf_parts*/
        end. /*if available buf_user-obj then do:*/
      end.
      {&assign-nums}.
    end. /*for each bf_hist*/
  end.  /*when "parts-rsrv-last-date":U*/
  when "parts-fib":U
  or
  when "parts-ean-fib":U
  then do:
    for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      assign
      v-curr-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-curr-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-curr-obj-type
              AND buf_user-obj.obj-code = v-curr-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each buf_parts no-lock where
                  buf_parts.obj-type = v-obj-type
                and buf_parts.obj-code = v-obj-code
                and buf_parts.out-code  = {&free-code}
                and buf_parts.status_   = false:
            if buf_parts.defect  = logical({&FiB}) then do:
              v-b-code = 0.
              { gbl/partbcod.i
                buf_parts
                v-b-code
                no-error
              }
              if v-b-code > 0 then do:
                find first buf_bar-code no-lock where
                          buf_bar-code.b-code = v-b-code no-error.
                if available buf_bar-code then do:
                  find first ub.goods no-lock where
                            ub.goods.gds-code = buf_bar-code.gds-code no-error.
                  if available ub.goods then do:
                    run get-prt-and-unit in this-procedure (
                                                                  input goods.prt-root
                                                                  ,input goods.unit-base
                                                                  ,output l-empty-scale
                                                        ) .
                    if rs-list-method = "parts-fib" then do:
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,input no, input "":U, input no, buffer buf_bar-code, buffer prod-bc).
  end.
                    if rs-list-method = "parts-ean-fib" then do:
                      RUN gen-bc( input buf_bar-code.b-code, output bar_code ).
                      IBM-good-code  = trim( bar_code ) .
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input IBM-good-code, input yes, buffer buf_bar-code, buffer buf_prod-bc).
                    end.
                  end.
                end.
              end.
            end. /*      if buf_parts.last-date - today < vvalue-int then do:*/
          end. /*for each buf_parts*/
        end. /*if available buf_user-obj then do:*/
      end.
      {&assign-nums}.
    end. /*for each bf_hist*/
  end. /*when "parts-fib":U then do:*/
  when "parts-rsrv-fib":U
  or
  when "parts-ean-rsrv-fib":U
  then do:
    for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      assign
      v-curr-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-curr-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-curr-obj-type
              AND buf_user-obj.obj-code = v-curr-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each buf_parts no-lock where
                  buf_parts.obj-type = v-obj-type
                and buf_parts.obj-code = v-obj-code
                and buf_parts.rsrv-free = true
                and buf_parts.status_   = false
                and buf_parts.out-code  <> {&free-code}
                :
            if buf_parts.defect = logical({&FiB}) then do:
              v-b-code = 0.
              { gbl/partbcod.i
                buf_parts
                v-b-code
                no-error
              }
              if v-b-code > 0 then do:
                find first buf_bar-code no-lock where
                          buf_bar-code.b-code = v-b-code no-error.
                if available buf_bar-code then do:
                  find first ub.goods no-lock where
                            ub.goods.gds-code = buf_bar-code.gds-code no-error.
                  if available ub.goods then do:
                    run get-prt-and-unit in this-procedure (
                                                                  input goods.prt-root
                                                                  ,input goods.unit-base
                                                                  ,output l-empty-scale
                                                        ) .
                    if rs-list-method = "parts-rsrv-fib" then do:
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,input no, input "":U, input no, buffer buf_bar-code, buffer prod-bc).
                    end.
                    if rs-list-method = "parts-ean-rsrv-fib" then do:
                      RUN gen-bc( input buf_bar-code.b-code, output bar_code ).
                      IBM-good-code  = trim( bar_code ) .
                      run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input IBM-good-code, input yes, buffer buf_bar-code, buffer buf_prod-bc).
                    end.
                  end.
                end.
              end.
            end. /*      if buf_parts.last-date - today < vvalue-int then do:*/
          end. /*for each buf_parts*/
        end. /*if available buf_user-obj then do:*/
      end.
      {&assign-nums}.
    end. /*for each bf_hist*/
  end. /*when "parts-rsrv-fib":U*/
  when "parts-end-date-obj":U
  or
  when "parts-ean-end-date-obj":U
  then do:
     for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      assign
      v-curr-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-curr-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
      v-from-date =     date(entry(3, buf_{1}-hist.item_, {&delim-key}))
      v-to-date = date(entry(4, buf_{1}-hist.item_, {&delim-key}))
      v-from-date-str = substitute("&1-&2-&3", string(year(v-from-date), "9999")
                                             , string(month(v-from-date), "99")
                                             , string(day(v-from-date), "99"))
      v-to-date-str   = substitute("&1-&2-&3", string(year(v-to-date), "9999")
                                              ,string(month(v-to-date), "99")
                                              ,string(day(v-to-date), "99"))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-curr-obj-type
              AND buf_user-obj.obj-code = v-curr-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each buf_parts-obj-attr no-lock where
                  buf_parts-obj-attr.obj-type = v-curr-obj-type
              and buf_parts-obj-attr.obj-code = v-curr-obj-code
              and buf_parts-obj-attr.attr-code = {&partoatr-parts-end}
              and buf_parts-obj-attr.attr-value >= v-from-date-str
              and buf_parts-obj-attr.attr-value < v-to-date-str:
            find first ub.goods no-lock where
                      ub.goods.gds-code = buf_parts-obj-attr.gds-code no-error.
            if available ub.goods then do:
              find first buf_bar-code no-lock where
                   buf_bar-code.gds-code = buf_parts-obj-attr.gds-code
               and buf_bar-code.in-code = buf_parts-obj-attr.in-code
               and buf_bar-code.part-code = buf_parts-obj-attr.part-code
               and buf_bar-code.unit-cli = ub.goods.unit-base
               /*and buf_bar-code.node-code = buf_parts-obj-attr.prt-code*/
                   no-error.
              if available buf_bar-code then do:
                run get-prt-and-unit in this-procedure (
                                                              input goods.prt-root
                                                              ,input goods.unit-base
                                                              ,output l-empty-scale
                                                    ) .
                if rs-list-method = "parts-end-date-obj" then do:
                  run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,input no, input "":U, input no, buffer buf_bar-code, buffer prod-bc).
                end.
                if rs-list-method = "parts-ean-end-date-obj" then do:
                  RUN gen-bc( input buf_bar-code.b-code, output bar_code ).
                  IBM-good-code  = trim( bar_code ) .
                  run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input IBM-good-code, input yes, buffer buf_bar-code, buffer buf_prod-bc).
                end.
              end. /*if available buf_bar-code then do:*/
            end. /*if available ub.goods then do:*/
          end. /*          for each buf_parts-obj-attr no-lock where*/
        end. /*if available buf_user-obj then do:*/
      end.
      {&assign-nums}.
    end. /*for each bf_hist*/
  end. /*"parts-end-date-obj":U*/
  when "loc-sc-codes":U
  or when "loc-pg-codes":U
  then do:
    for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      assign
      v-db-num = integer(entry(1, buf_{1}-hist.item_, {&delim-key}))
      v-using = (entry(2, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then do:
      end.
      else do:
        for each buf_code-range no-lock where
                buf_code-range.range-type = (if rs-list-method = "loc-sc-codes"
                                             then {&loc-sc-code}
                                             else {&loc-pg-code}):
          if v-db-num = g#db-num then do:
            _prod-bc:
            for each buf_prod-bc no-lock where
                    buf_prod-bc.b-str >= string(buf_code-range.first-code, "99999")
              and  buf_prod-bc.b-str <= string(buf_code-range.last-code, "99999")
            on error undo, return error
            :
              if length( buf_prod-bc.b-str ) < 6 then do:
                /*проверим действительно ли весовой*/
                assign
                l-prod-bc-weight   = no
                l-prod-bc-pgweight = no
                .
                if buf_code-range.range-type = {&loc-sc-code} then do:
                  { gbl/prodbcat.i
                    buf_prod-bc
                    "'weight=request':u"
                    l-prod-bc-weight
                    no-error
                  }
                  if not l-prod-bc-weight then next _prod-bc.
                end.
                else do:
                  { gbl/prodbcat.i
                    buf_prod-bc
                    "'pgweight=request':u"
                    l-prod-bc-pgweight
                    no-error
                  }
                  if not l-prod-bc-pgweight then next _prod-bc.
                end.
                find first buf_bar-code no-lock
                  where buf_bar-code.b-code = buf_prod-bc.b-code
                .
                if available buf_bar-code then do:
                  find first ub.goods no-lock
                    where ub.goods.gds-code = buf_bar-code.gds-code
                    no-error
                  .
                  case v-using:
                    when "all" then do:
                      /*нужны все коды*/
                    end.
                    otherwise do:
                      /*нужны только используемые коды*/
                      _gds-obj-attr:
                      for each buf_clients no-lock where
                              buf_clients.db-num = v-db-num,
                          each buf_gds-obj-attr no-lock where
                              buf_gds-obj-attr.obj-type = buf_clients.obj-type
                         and  buf_gds-obj-attr.obj-code = buf_clients.obj-code
                         and  buf_gds-obj-attr.gds-code = ub.goods.gds-code :
                        if buf_gds-obj-attr.attr-value = buf_prod-bc.b-str
                        and v-using = "nonusing" then do:
                          find first buf_scales-gds no-lock where
                                  buf_scales-gds.db-num = v-db-num
                              and buf_scales-gds.obj-type = buf_clients.obj-type
                              and buf_scales-gds.obj-code = buf_clients.obj-code
                              and buf_scales-gds.b-code = buf_bar-code.b-code no-error.
                          if available buf_scales-gds then do:
                            next _prod-bc.
                          end.
                        end.
                        if buf_gds-obj-attr.attr-value = buf_prod-bc.b-str
                        and v-using = "using" then do:
                          leave _gds-obj-attr.
                        end.
                      end.
                      if v-using = "using"
                      and not available buf_gds-obj-attr then next _prod-bc.
                    end.
                  end case.
                  run get-prt-and-unit in this-procedure (
                                                           input ub.goods.prt-root
                                                          ,input ub.goods.unit-base
                                                          ,output l-empty-scale
                                                          ) .
                  run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,  input l-empty-scale, input buf_prod-bc.b-str, input no, buffer buf_bar-code, buffer buf_prod-bc).
                end. /*if available buf_bar-code then do:*/
              end. /*if length( buf_prod-bc.b-str ) < 6 then do:*/
            end. /*        for each buf_prod-bc no-lock*/
          end. /*if v-db-num = g#db-num then do:*/
          else do:
            if g#db-num = 0 then do:
              _prod-bc-db:
              for each buf_prod-bc-db no-lock where
                      buf_prod-bc-db.b-str >= string(buf_code-range.first-code, "99999")
                and  buf_prod-bc-db.b-str <= string(buf_code-range.last-code, "99999")
                and buf_prod-bc-db.db-num = v-db-num
              on error undo, return error
              :
                if length( buf_prod-bc-db.b-str ) < 6 then do:
                  find first buf_bar-code no-lock
                    where buf_bar-code.b-code = buf_prod-bc-db.b-code
                  .
                  if available buf_bar-code then do:
                    find first ub.goods no-lock
                      where ub.goods.gds-code = buf_bar-code.gds-code
                      no-error
                    .
                    /*проверим действительно ли */
                    if buf_code-range.range-type = {&loc-sc-code} then do:
                      { gbl/prodbctv.i
                        buf_prod-bc-db.b-str
                        buf_bar-code.unit-cli
                        ub.goods.unit-base 'weight=request':U
                        l-prod-bc-weight
                      no-error }
                      if not l-prod-bc-weight then next _prod-bc-db.
                    end.
                    else do:
                      { gbl/prodbctv.i
                        buf_prod-bc-db.b-str
                        buf_bar-code.unit-cli
                        ub.goods.unit-base 'weight=request':U
                        l-prod-bc-pgweight
                      no-error }
                      if not l-prod-bc-pgweight then next _prod-bc-db.
                    end.
                    case v-using:
                      when "all" then do:
                        /*нужны все коды*/
                      end.
                      otherwise do:
                        /*нужны только используемые коды*/
                        _gds-obj-attr:
                        for each buf_clients no-lock where
                                buf_clients.db-num = v-db-num,
                            each buf_gds-obj-attr no-lock where
                                buf_gds-obj-attr.obj-type = buf_clients.obj-type
                          and  buf_gds-obj-attr.obj-code = buf_clients.obj-code
                          and  buf_gds-obj-attr.gds-code = ub.goods.gds-code :
                          if buf_gds-obj-attr.attr-value = buf_prod-bc-db.b-str
                          and v-using = "nonusing" then do:
                            find first buf_scales-gds no-lock where
                                    buf_scales-gds.db-num = v-db-num
                                and buf_scales-gds.obj-type = buf_clients.obj-type
                                and buf_scales-gds.obj-code = buf_clients.obj-code
                                and buf_scales-gds.b-code = buf_bar-code.b-code no-error.
                            if available buf_scales-gds then do:
                              next _prod-bc-db.
                            end.
                          end.
                          if buf_gds-obj-attr.attr-value = buf_prod-bc-db.b-str
                          and v-using = "using" then do:
                            leave _gds-obj-attr.
                          end.
                        end.
                        if v-using = "using"
                        and not available buf_gds-obj-attr then next _prod-bc-db.
                      end.
                    end case.
                    run get-prt-and-unit in this-procedure (
                                                            input ub.goods.prt-root
                                                            ,input ub.goods.unit-base
                                                            ,output l-empty-scale
                                                            ) .
                    run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,  input l-empty-scale, input buf_prod-bc-db.b-str, input no, buffer buf_bar-code, buffer buf_prod-bc).
                  end. /*if available buf_bar-code then do:*/
                end. /*if length( buf_prod-bc.b-str ) < 6 then do:*/
              end. /*        for each buf_prod-bc no-lock*/
            end. /*if g#db-num = 0 then do:*/
          end. /*else if v-db-num = g#db-num then do:*/
        end. /*        for each buf_code-range no-lock where */
      end. /*else if error-status:error then do:*/
      {&assign-nums}.
    end. /*for each bf_hist*/
  end. /*when "loc-sc-codes":U then do:*/
  when "gbl-sc-codes":U
  then do:
    for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      assign
      v-db-num = integer(entry(1, buf_{1}-hist.item_, {&delim-key}))
      v-using = (entry(2, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then do:
      end.
      else do:
        for each buf_code-range no-lock where
                buf_code-range.range-type = {&gbl-sc-code}
            and buf_code-range.db-num = v-db-num     :
          _prod-bc:
          for each buf_prod-bc no-lock where
                  buf_prod-bc.b-str >= string(buf_code-range.first-code, "99999")
            and  buf_prod-bc.b-str <= string(buf_code-range.last-code, "99999")
          on error undo, return error
          :
            if length( buf_prod-bc.b-str ) < 6 then do:
              /*проверим действительно ли весовой*/
              assign
              l-prod-bc-weight   = no
              l-prod-bc-glob = no
              .

              { gbl/prodbcat.i
                buf_prod-bc
                "'weight=request':u"
                l-prod-bc-weight
                no-error
              }
              if not l-prod-bc-weight then next _prod-bc.
              { gbl/prodbcat.i
                buf_prod-bc
                "'global=request':u"
                l-prod-bc-glob
                no-error
              }
              if not l-prod-bc-glob then next _prod-bc.
              find first buf_bar-code no-lock
                where buf_bar-code.b-code = buf_prod-bc.b-code
              .
              if available buf_bar-code then do:
                find first ub.goods no-lock
                  where ub.goods.gds-code = buf_bar-code.gds-code
                  no-error
                .
                case v-using:
                  when "all" then do:
                    /*нужны все коды*/
                  end.
                  otherwise do:
                    /*нужны только используемые коды*/
                    _gds-obj-attr:
                    for each buf_clients no-lock where
                            buf_clients.db-num = v-db-num,
                        each buf_gds-obj-attr no-lock where
                            buf_gds-obj-attr.obj-type = buf_clients.obj-type
                        and  buf_gds-obj-attr.obj-code = buf_clients.obj-code
                        and  buf_gds-obj-attr.gds-code = ub.goods.gds-code :
                      if buf_gds-obj-attr.attr-value = buf_prod-bc.b-str
                      and v-using = "nonusing" then do:
                        find first buf_scales-gds no-lock where
                                buf_scales-gds.db-num = v-db-num
                            and buf_scales-gds.obj-type = buf_clients.obj-type
                            and buf_scales-gds.obj-code = buf_clients.obj-code
                            and buf_scales-gds.b-code = buf_bar-code.b-code no-error.
                        if available buf_scales-gds then do:
                          next _prod-bc.
                        end.
                      end.
                      if buf_gds-obj-attr.attr-value = buf_prod-bc.b-str
                      and v-using = "using" then do:
                        leave _gds-obj-attr.
                      end.
                    end.
                    if v-using = "using"
                    and not available buf_gds-obj-attr then next _prod-bc.
                  end.
                end case.
                run get-prt-and-unit in this-procedure (
                                                          input ub.goods.prt-root
                                                        ,input ub.goods.unit-base
                                                        ,output l-empty-scale
                                                        ) .
                run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode ,  input l-empty-scale, input buf_prod-bc.b-str, input no, buffer buf_bar-code, buffer buf_prod-bc).
              end. /*if available buf_bar-code then do:*/
            end. /*if length( buf_prod-bc.b-str ) < 6 then do:*/
          end. /*        for each buf_prod-bc no-lock*/
        end. /*        for each buf_code-range no-lock where */
      end. /*else if error-status:error then do:*/
      {&assign-nums}.
    end. /*for each bf_hist*/
  end. /*when "loc-sc-codes":U then do:*/

  when "filter" then do:
    define variable v-filter-var as character no-undo .
    find first buf_{1}-hist where
            buf_{1}-hist.id = p-id
        AND buf_{1}-hist.item_ <> '':U .
    run proc-write-filter-expression-var in this-procedure ( input buf_{1}-hist.item_, output v-filter-var ).
    &if "{1}" = "scnblist" &then
    run gbl/scnbfill.p (
    &else
    run gbl/bb-fill.p (
    &endif
                    input "Формирование списка по фильтру (без учета сортировки)"
                  , input rs-list-method
                  , input rs-status
                  , input line-mode
                  , input v-filter-var
                  , output lns-cnt
                  , output line-rec
                  ) .
    {&assign-nums}.
  end.
end.
dsp-rs:fgcolor in frame {&frame-name} = 4.
if session:set-wait-state( "" )  then .
case line-mode :
  when {&add-def} then do:
    tot-lns = tot-lns + lns-cnt.
    if not p-from-macro or p-step then
    message
    "Добавлено строк :" lns-cnt skip(0)
    string(if lns-ignore <> 0
    then ("Проигнорировано строк :" + string(lns-ignore))
    else "":U)
    .
  end.
  when {&deletion} then do:
    tot-lns = tot-lns - lns-cnt.
    if not p-from-macro or p-step then
    message
    "Удалено строк :" lns-cnt skip(0)
    string(if lns-ignore <> 0
    then ("Проигнорировано строк :" + string(lns-ignore))
    else "":U)
    .
  end.
end.

if line-mode <> {&leave} then  run UI-on.
end. /*doe*/
END PROCEDURE.

procedure proc-file-list-methods :
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .
define variable ss as character no-undo .
define variable b-c as integer no-undo.
define variable imp-type like ub.goods.prod-type no-undo.
define variable imp-code like ub.goods.prod-code no-undo.
define variable imp-art like ub.goods.artic no-undo.
define variable imp-doc-code like ub.trn-doc.doc-code no-undo.
define variable imp-doc-type as character no-undo.
define variable scan-qnty as dec no-undo.                /* количество, введенное при сканировании */
define variable bc-qnty as dec no-undo.                  /* коэффициент (вес) из бар-кода */
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define buffer buf_{1}-hist for {1}-hist.

do
on error undo, return error
:

find first buf_{1}-hist where
          buf_{1}-hist.id = p-id
      AND buf_{1}-hist.item_ <> '':U .
run gbl/filename.p
  (input  entry(1, buf_{1}-hist.item_, {&delim-par} ) /* p-search-file-name */
  ,output v-full-path         /* p-full-path        */
  ,output v-path              /* p-path             */
  ,output v-file-name         /* p-file-name        */
  ,output v-file-name-no-ext  /* p-file-name-no-ext */
  ,output v-file-name-ext     /* p-file-name-ext    */
  ) no-error .
  if error-status:error then do: end. else do:

  input stream sout from value (v-full-path).

  CASE rs-list-method:
    when "file-gds" then do:
      if p-from-macro then
      run restore-codes in this-procedure (input entry(2, buf_{1}-hist.item, {&delim-par}), input p-curr-obj-type, input p-curr-obj-code).
      repeat:
          import stream sout imp-type imp-code imp-art scan-qnty no-error.
          find ub.goods where ub.goods.prod-type = imp-type
                      and ub.goods.prod-code = imp-code
                      and ub.goods.artic     = imp-art no-lock no-error.
          if available ub.goods then do:
            {&NEW-GOOD}
            run process-one-good in this-procedure (input rs-list-method, input rs-status, input line-mode ,buffer goods) no-error .
          end.
        end.
    end.
    when "scaner" then do:
      &if "{1}" = "scnblist" &then
      message "При чтении из файла количеств они будут прибавлены к количествам в списке.".
      &endif
       repeat:
        import stream sout unformatted ss.
        ss = trim (ss).
        if ss = "" then next.
        if substr (ss, 1, 1) < "0" or substr (ss, 1, 1) > "9" then
          if substr (ss, 1, 4) = "data" then ss = entry (2, ss, ":").
          else next.
          assign
          scan-qnty = dec (entry (2, ss))                 /* количество, введенное при сканировании */
          ss = trim (entry (1, ss)).
        { str/bc-rcnz.i
          parparentproc
          ss
          ?
          p-curr-obj-type
          p-curr-obj-type
          yes
          no
          varscales-pref
          varpgscales-pref
          varresult
          vartype-bc
          varweight
          ub.bar-code
          ub.prod-bc
          ub.place
          no-error
        }
        if not available ub.bar-code then next.
        bc-qnty = ub.bar-code.cli-base-rate.
        {&NEW-GOOD}
        find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK no-error.
        if available ub.goods then do:
          run get-prt-and-unit in this-procedure (
                                                  input ub.goods.prt-root
                                                  ,input ub.goods.unit-base
                                                  ,output l-empty-scale
                                                  ) .
          run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input "":U, input (not available prod-bc), buffer bar-code, buffer prod-bc).
          /* количество пишем, если есть запись (не удаление и не попытка добавить удаленный товар),
            если это не запись, оставшаяся от предыдущего цикла */
          if available {1} and
            {1}.artic = ub.goods.artic and
            {1}.prod-type = ub.goods.prod-type and
            {1}.prod-code = ub.goods.prod-code then
            {1}.qnty = {1}.qnty + scan-qnty * bc-qnty.               /* умножаем на коэффициент (вес) из бар-кода */
        end. /*if available goods then do:*/
      end. /*repeate*/
    end. /*when*/
  END CASE.
  input stream sout close.
  {&assign-nums}.
  end.
end.
END PROCEDURE.


PROCEDURE write-hist :
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define parameter buffer buf_goods for ub.goods.
define variable v-ii as integer no-undo .
define variable v-temp-seq as integer no-undo .
/* запись истории формирования списка */
if rs-list-method begins "single" then do:
  if v-no-hist < 0 then do:
    run create-{1}-hist in this-procedure(input {&add-def}
                                        , input-output v-seq
                                        , input 0
                                        , input get-hist-mode(line-mode)
                                        , input (if line-mode = {&add-def}
                                                then (substitute("Коды по ТОВАРУ c гл.кодом &1 &2 &3&4 &5 -"
                                                          , buf_goods.gds-code
                                                          , buf_goods.artic
                                                          , buf_goods.prod-type
                                                          , buf_goods.prod-code
                                                          , buf_goods.gds-name) +
                                                       {&codes-labels})
                                                else substitute("КОД &1 товар c гл.кодом &2 &3 &4&5 &6"
                                                          , (if {1}.b-str <> '':U then {1}.b-str else string({1}.b-code))
                                                          , {1}.gds-code
                                                          , {1}.artic
                                                          , {1}.prod-type
                                                          , {1}.prod-code
                                                          , {1}.gds-name)

                                                )
                                        , input tot-lns
                                        , input (rs-list-method + (if line-mode = {&add-def}
                                                                  then '':U
                                                                  else ({&delim-par} + (if {1}.b-str <> '':U
                                                                                        then {&table_prod-bc}
                                                                                        else (if {1}.loc-ean
                                                                                              then 'loc-ean':U
                                                                                              else {&table_bar-code})
                                                                                        )
                                                                        )
                                                                  )
                                                )
                                        , input rs-status
                                        , input (if line-mode = {&add-def}
                                                 then ({&table_goods} + {&delim-key} + string(buf_goods.gds-code) + {&delim-par} +
                                                       {&codes-values})
                                                 else (if {1}.b-str <> '':u and {1}.loc-ean = no
                                                      then ({&table_prod-bc} + {&delim-key} + {1}.b-str)
                                                      else ({&table_bar-code} + {&delim-key} + string({1}.b-code))
                                                      )
                                                 )
                                        , input '':U
                                        , input ?
                                        ).
  end.
  else do:
    v-temp-seq = v-seq - 1.
    do v-ii = 0 to v-no-hist:
      run create-{1}-hist in this-procedure(input ({&update} + {&delim-par} + 'mode':U)
                                          , input-output v-temp-seq
                                          , input v-ii
                                          , input get-hist-mode(line-mode)
                                          , input (substitute("Коды по ТОВАРУ c гл.кодом &1 &2 &3&4 &5 -"
                                                            , {1}.gds-code
                                                            , {1}.artic
                                                            , {1}.prod-type
                                                            , {1}.prod-code
                                                            , {1}.gds-name) +
                                                   {&codes-labels})
                                          , input tot-lns
                                          , input '':U
                                          , input '':U
                                          , input ('goods':U + {&delim-key} + string({1}.gds-code) +
                                                  {&codes-values})
                                          , input '':U
                                          , input ?
                                          ).
    end.
  end.
end.
else do:
  v-temp-seq = v-seq - 1.
  do v-ii = 0 to v-no-hist:
    run create-{1}-hist in this-procedure(input ({&update} + {&delim-par} + 'mode':U)
                                        , input-output  v-temp-seq
                                        , input v-ii
                                        , input get-hist-mode(line-mode)
                                        , input '':U
                                        , input tot-lns
                                        , input rs-list-method
                                        , input '':U
                                        , input '':U
                                        , input '':U
                                        , input ?
                                        ).
  end.
end.
END. /*write-hist*/


FUNCTION stat-line RETURNS CHARACTER(input p-status-chr as character):
/*функция возвращает строку для message и для dsp-rs*/
DEFINE VARIABLE var-stat-line as character no-undo .

CASE p-status-chr:
  when {&all} then do:
    assign
    var-stat-line = "(текущие и удаленные товары)"
    .
  end.
  when {&current} then do:
    assign
    var-stat-line = "(текущие товары)"
    .
  end.
  when {&deleted} then do:
    assign
    var-stat-line = "(неактивные товары)"
    .
  end.
END CASE.
return var-stat-line .

END.

procedure proc-vc-rs-list-method :
define variable v-operation as integer no-undo .
define variable main-code like ub.bar-code.b-code no-undo .
define variable v-chk-date-chr as character no-undo .
define variable dsp-rs-option as character no-undo .
define variable v-curr-host-code like ub.sysconf.host-code no-undo .
define variable v-item_ as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-recs as integer   no-undo .
define variable v-temp-seq as integer   no-undo .
define variable v-line as integer   no-undo .
define variable v-tot-lns as integer   no-undo .
define variable f-name as character no-undo .
define variable rid-list as character no-undo .
define variable bar_code as character no-undo .
define variable v-jj as integer no-undo .
define variable v-rid as recid no-undo .

define buffer buf_{1}-hist for {1}-hist.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.

define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_db for ub.db.

  do
  on error undo, return error
  :

  assign
  frame {&frame-name}
  T-all-prt
  &if "{&ean-option}" <> "no" &then
  T-bc-alt
  T-bc-base
  &endif
  T-loc-alt
  T-loc-base
  &if "{&parts-option}" <> "no" &then
  T-parts-all
  T-parts-not-blank
  T-parts-ser
  &endif
  &if "{&pbc-option}" <> "no" &then
  T-pb-alt
  T-pb-base
  T-sc-base
  &endif
  .
  if (
  T-all-prt or
  T-bc-alt  or
  T-bc-base or
  T-loc-alt or
  T-loc-base  or
  T-parts-all  or
  T-parts-not-blank or
  T-parts-ser or
  T-pb-alt    or
  T-pb-base   or
  T-sc-base) = no then do:
    message
    "Не выбран ни один тип кодов!"
    view-as alert-box error .
    undo, return error .
  end.

  assign
  temp-shop.obj-code = p-curr-obj-code
  temp-shop.all-prt = T-all-prt
  temp-shop.cd-bc-alt = T-bc-alt
  temp-shop.cd-bc-base = T-bc-base
  temp-shop.cd-loc-alt = T-loc-alt
  temp-shop.cd-loc-base = T-loc-base
  temp-shop.cd-parts-all = T-parts-all
  temp-shop.cd-parts-not-blank = T-parts-not-blank
  temp-shop.cd-parts-ser = T-parts-ser
  temp-shop.cd-pb-alt = T-pb-alt
  temp-shop.cd-pb-base = T-pb-base
  temp-shop.cd-sc-base = T-sc-base
  .

    v-no-hist = - 1.
    if temp-list.fvalue = "single" then
      run UI-on.
    else do:
      v-no-hist = 0.
      case rs-list-method:
        when "all" then do:
          glog = yes.
          message "Коды выбранных типов для всех товаров из справочника товаров"
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error .
          end.
          v-no-hist = 1.
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input (substitute('Коды всех товаров &1 - ', stat-line(rs-status)) +
                                                     {&codes-labels})
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input {&codes-values}
                                              , input '':U
                                              , input ?
                                              ).
        end.
        when "goods"
        or
        when "goods-b-code"
        or
        when "goods-b-code-ean"
        or
        when "goods-b-str"
        then do:
          glog = yes.
          case rs-list-method:
            when "goods" then do:
              assign
              dsp-rs-option = substitute("Заданные типы кодов для товаров: &1", stat-line(rs-status)) +
                              {&codes-labels}
              v-item_ = {&codes-values}
            .
            end.
            when "goods-b-code" then do:
              assign
              dsp-rs-option = substitute("Основн. и неосновн. лок.коды для товара: &1", stat-line(rs-status))
              v-tbl-name = {&table_bar-code}
              v-bh       = buffer ub.goods:handle
             .
            end.
            when "goods-b-code-ean" then do:
              assign
              dsp-rs-option = substitute("Основн. и неосновн. лок.коды EAN для товара: &1", stat-line(rs-status))
              v-tbl-name = {&table_bar-code}
              v-bh       = buffer buf_bar-code:handle
             .
            end.
            when "goods-b-str" then do:
              assign
              dsp-rs-option = substitute("Основн. и неосновн. Доп.БК для товара: &1", stat-line(rs-status))
              v-tbl-name = {&table_prod-bc}
              v-bh       = buffer buf_prod-bc:handle
             .
            end.
          END CASE.
          if not glog then do:
            run UI-on.
            return error.
          end.
          run ref/gds-ref.p (  input parparentproc
                          ,input (if rs-list-method = "goods":U
                                  then "b-sel,b-mark,b-add"
                                  else "b-sel,b-add")
                          ,input ?                      /*p-stat */
                          ,input ?                      /*p-list  */
                          ,input  {&g___object}         /*p-cond  */
                          ,input ?                      /*p-rec   */
                          ,input ?                      /*p-grp   */
                          ,input ?                      /*p-cli-type */
                          ,input ?                      /*p-cli-code  */
                          ,input p-curr-obj-type             /*p-obj-type  */
                          ,input p-curr-obj-code              /*p-obj-code  */
                          ,input ?                      /*p-other     */
                          ,output ref-list).
          if ref-list <> "" then do:
            if rs-list-method = "goods-b-code":U
            or rs-list-method = "goods-b-code-ean":U
            then do:
              v-ref-rec = integer (entry (1, ref-list)).
              find ub.goods where recid (ub.goods) = v-ref-rec no-lock.
              { gbl/gdsbcode.i ub.goods.gds-code ? main-code no-error }
              if error-status:error then do:
                run UI-on.
                return error.
              end.
              run ref/alt-cds.w (input parparentproc
                            ,input p-curr-obj-type
                            ,input p-curr-obj-code
                            ,input "all-no-part"
                            ,input ub.goods.gds-code
                            ,input main-code
                            ,output rid-list) no-error .
              if error-status:error or rid-list = "" then do:
                run UI-on.
                return error.
              end.
            end. /**/
            if rs-list-method = "goods-b-str":U
            then do:
              v-ref-rec = integer (entry (1, ref-list)).
              find ub.goods where recid (ub.goods) = v-ref-rec no-lock.
              { gbl/gdsbcode.i ub.goods.gds-code ? main-code no-error }
              if error-status:error then do:
                run UI-on.
                return error.
              end.
              run ref/prod-cds.w (
                              input parparentproc
                            , input p-curr-obj-type
                            , input p-curr-obj-code
                            , input "all-no-part"
                            , input goods.gds-code
                            , input main-code
                            , output rid-list) no-error .
              if error-status:error or rid-list = "" then do:
                run UI-on.
                return error.
              end.
            end. /**/
            v-recs = num-entries (ref-list).
            if rs-list-method = 'goods' then do:
              do num-rec = 0 to v-recs:
                if num-rec > 0
                then do:
                  v-ref-rec = integer (entry (num-rec, ref-list)).
                  find goods where recid (goods) = v-ref-rec no-lock.
                end.
                if num-rec = 0 then do:
                  assign
                  v-temp-seq = v-seq
                  v-line     = 0
                  dsp-rs = dsp-rs-option
                  v-item_     = {&codes-values}
                  v-tbl-name = '':U
                  v-bh       = ?
                  v-tot-lns = tot-lns
                  .
                end.
                else do:
                  assign
                  v-temp-seq = v-seq - 1
                  v-line     = num-rec
                  dsp-rs =  substitute("     гл. код &1 &2 &3&4 &5", goods.gds-code, goods.artic, goods.prod-type, goods.prod-code, goods.gds-name)
                  v-item_     = '':U
                  v-tbl-name = {&table_goods}
                  v-bh       = buffer goods:handle
                  v-tot-lns = tot-lns + num-rec
                  .
                end.
                v-no-hist = num-rec.
                run create-{1}-hist in this-procedure(input {&add-def}
                                                    , input-output v-temp-seq
                                                    , input v-line
                                                    , input '':U
                                                    , input dsp-rs
                                                    , input v-tot-lns
                                                    , input rs-list-method
                                                    , input rs-status
                                                    , input v-item_
                                                    , input v-tbl-name
                                                    , input v-bh
                                                    ).
                if num-rec = 0 then v-seq  = v-temp-seq.
              end. /*do num-rec*/
            end. /*if rs-list-method = 'goods' then do:*/
            else do:
              do num-rec = 0 to v-recs:
                do v-jj = 1 to num-entries(rid-list):
                  if num-rec = 0
                  and v-jj = 1
                  then do:
              v-ref-rec = integer (entry (1, ref-list)).
              find goods where recid (goods) = v-ref-rec no-lock.
              assign
                  v-temp-seq = v-seq
                  v-line     = 0
                  dsp-rs = dsp-rs-option
                  v-item_     = '':U
                  v-tbl-name = '':U
                  v-bh       = ?
                  v-tot-lns = tot-lns
                  .
                end.
                else do:
                  if rs-list-method = "goods-b-code":U
                  or rs-list-method = "goods-b-code-ean":U then do:
                    find first buf_bar-code no-lock where
                              recid(buf_bar-code) = integer(entry(v-jj, rid-list)) no-error .
                    if rs-list-method = "goods-b-code" then
                    bar_code = string(buf_bar-code.b-code).
                    else
                    RUN gen-bc in this-procedure ( input main-b-code, output bar_code ).
                  end.
                  else do:
                    find first buf_prod-bc no-lock where
                                recid(buf_prod-bc) = integer(entry(v-jj, rid-list)) no-error .
                    bar_code = buf_prod-bc.b-str.
                  end.
                  assign
                  v-temp-seq = v-seq - 1
                  v-line     = num-rec
              dsp-rs = dsp-rs-option + {&space-char} +
                       substitute("Код &1 гл. код &2 &3 &4&5 &6"
                                 , bar_code
                                 , goods.gds-code
                                 , goods.artic
                                 , goods.prod-type
                                 , goods.prod-code
                                 , goods.gds-name)
                  v-item_     = '':u
                  v-tbl-name = if rs-list-method = "goods-b-code":U
                               or rs-list-method = "goods-b-code-ean":U
                               then {&table_bar-code}
                               else {&table_prod-bc}
                  v-bh       = if rs-list-method = "goods-b-code":U
                               or rs-list-method = "goods-b-code-ean":U
                               then buffer buf_bar-code:handle
                               else buffer buf_prod-bc:handle
                  v-tot-lns = tot-lns + num-rec
              .
                end.
                v-no-hist = num-rec.
              run create-{1}-hist in this-procedure(input {&add-def}
                                                  , input-output v-temp-seq
                                                  , input v-line
                                                  , input '':U
                                                  , input dsp-rs
                                                  , input v-tot-lns
                                                  , input rs-list-method
                                                  , input rs-status
                                                  , input v-item_
                                                  , input v-tbl-name
                                                  , input v-bh
                                                  ).
                if num-rec = 0 then v-seq  = v-temp-seq.
                end. /* do v-jj = 1 to num-entries(rid-list):*/
            end. /*do num-rec*/
            end. /*if не goods*/
          end. /*ref-list <> '':U*/
          else do:
            run UI-on.
            return error.
          end.
        end.
        when "gds-list":U then do:
          glog = yes.
          message "Коды выбранных типов для товаров, выбранных в список"
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error.
          end.
          for each gds-list:
            delete gds-list.
          end.
          v-recs = 0.
          num-rec = 0.
          { gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-curr-host-code }
          run str/gds-list.w (input parparentproc, input v-curr-host-code, input p-curr-obj-type, input p-curr-obj-code).
          for each gds-list,
            first goods no-lock where goods.gds-code = gds-list.gds-code:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs-option = substitute("Коды выбранных типов товаров по списку: &1 - &2", rs-status, {&codes-labels})
              v-item_     = {&codes-values}
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
              run create-{1}-hist in this-procedure(input {&add-def}
                                                  , input-output v-temp-seq
                                                  , input v-line
                                                  , input '':U
                                                  , input dsp-rs-option
                                                  , input v-tot-lns
                                                  , input rs-list-method
                                                  , input rs-status
                                                  , input v-item_
                                                  , input v-tbl-name
                                                  , input v-bh
                                                  ).
              num-rec = 1.
              v-seq  = v-temp-seq.
              v-temp-seq = v-temp-seq - 1.
            end.
            if num-rec <> 0 then do:
              assign
              v-line     = num-rec
              dsp-rs = substitute("гл. код &1 &2 &3&4 &5", goods.gds-code, goods.artic, goods.prod-type, goods.prod-code, goods.gds-name)
              v-item_     = '':U
              v-tbl-name = {&table_goods}
              v-bh       = buffer goods:handle
              v-tot-lns = tot-lns + num-rec
              .
              run create-{1}-hist in this-procedure(input {&add-def}
                                                  , input-output v-temp-seq
                                                  , input v-line
                                                  , input '':U
                                                  , input dsp-rs-option + {&space-char} + dsp-rs
                                                  , input v-tot-lns
                                                  , input rs-list-method
                                                  , input rs-status
                                                  , input v-item_
                                                  , input v-tbl-name
                                                  , input v-bh
                                                  ).
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            num-rec =  num-rec + 1.
            delete gds-list.
            end. /*for each gd-slist*/
        end.
        when "file-gds" then do:
          glog = yes.
          message "Коды выбранных типов для товаров из ранее сохраненного в файле списка"
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error.
          end.
          system-dialog get-file f-name
          filters "Списки товаров *.gds" "*.gds"
          title "Выберите файл списка"
          INITIAL-DIR "."
          return-to-start-dir
          must-exist
          /* use-filename */
          update glog
          default-extension "gds".
          if not glog then do:
            run UI-on.
            return error.
          end.
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input substitute("Файл списка : &1 &2", f-name, stat-line(rs-status)) + {&space-char} +
                                                      {&codes-labels}
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input f-name + {&delim-par} + {&codes-values}
                                              , input '':U
                                              , input ?
                                              ).
        end.
        when "last-check":U then do:
          glog = yes.
          message "Коды продажи для бар-кода в чеках, пробитых не позже выбранной даты"
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error.
          end.
          {&sel-obj}
          run gbl/d-prompt.w
            ( 'title=Введите дату\'
            + 'format=99/99/9999\'
            + 'type=date\'
            ,input-output v-chk-date-chr
            ).
          if return-value = 'false':u then do:
            run UI-on.
            return error.
          end.
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input substitute("ВСЕ коды продажи для бар-кода в чеках &1&2, пробитых не позже &3 "
                                                                 , v-sel-obj-type
                                                                 , v-sel-obj-code
                                                                 , v-chk-date-chr)
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-sel-obj-type + {&delim-key} + string(v-sel-obj-code) + {&delim-key} + v-chk-date-chr
                                              , input '':U
                                              , input ?
                                              ).

        end.
        when "cd-codes":U then do:
          glog = yes.
          message "Коды продажи, привязанные к кассам"
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error.
          end.
          run ref/cashlist.w (
                          input parparentproc
                         ,input "b-sel"
                         ,input "db":U
                         ,input g#db-num
                         ,input 0 /*parhost-code */
                         ,input p-curr-obj-type /*paobj-type*/
                         ,input p-curr-obj-code /*parobj-code*/
                         ,input ?
                         ,output ref-list) no-error .
          if error-status:error or ref-list = "":u then do:
            run UI-on.
            return error.
          end.
          find first buf_cash-desk no-lock where
                    recid(buf_cash-desk) = integer(ref-list) no-error .
          if not available buf_cash-desk then do:
            run UI-on.
            return error.
          end.
          if buf_cash-desk.pos-type <> {&cd-type-r-keeper} then do:
            message
            substitute("Коды продажи на кассе определены только для кассы типа &1"
                      , {&cd-type-r-keeper})
            view-as alert-box error .
            run UI-on.
            return error.
          end.
          assign
          v-cash-num = buf_Cash-desk.cash-num
          v-pos-type = buf_Cash-desk.pos-type
          v-cash-desk-obj-code = buf_Cash-desk.obj-code
          .
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input substitute("Коды продажи для кассы &1 &2 &3&4"
                                                     , v-pos-type, v-cash-num, {&shop}, v-cash-desk-obj-code)
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input ({&shop} + {&delim-key} + string(v-cash-desk-obj-code) + {&delim-key} +
                                                      v-pos-type + {&delim-key} + string(v-cash-num))
                                              , input '':U
                                              , input ?
                                              ).

        end.
        when "parts-cashparts":U
        or
        when "parts-ean-cashparts"
        then do:
          run proc-parts-cashparts ( input rs-list-method) no-error.
          if error-status:error then do:
            run Ui-on in this-procedure.
            return no-apply.
          end.
        end.
        when "parts-last-date":U
        or
        when "parts-rsrv-last-date"
        or
        when "parts-ean-last-date":U
        or
        when "parts-ean-rsrv-last-date"
        then do:
          run proc-parts-last-date(rs-list-method) no-error.
          if error-status:error then do:
            run Ui-on in this-procedure.
            return no-apply.
          end.
        end.
        when "parts-fib":U
        or
        when "parts-rsrv-fib"
        or
        when "parts-ean-fib":U
        or
        when "parts-ean-rsrv-fib"
        then do:
          run proc-parts-fib(rs-list-method) no-error.
          if error-status:error then do:
            run Ui-on in this-procedure.
            return no-apply.
          end.
        end.
        when "parts-end-date-obj":U
        or
        when "parts-ean-end-date-obj"
        then do:
          run proc-parts-end(rs-list-method) no-error.
          if error-status:error then do:
            run Ui-on in this-procedure.
            return no-apply.
          end.
        end.
        when "loc-sc-codes"
        or
        when "loc-pg-codes"
        or
        when "gbl-sc-codes"
        then do:
          glog = yes.
          if rs-list-method = "loc-sc-codes" then do:
             if g#db-num = 0 then do:
               dsp-rs-option = substitute("Локальные весовые коды на выбранной БД: &1", stat-line(rs-status)).
             end.
          end.
          if rs-list-method = "gbl-sc-codes" then do:
             if g#db-num = 0 then do:
               dsp-rs-option = substitute("Глобальные весовые коды на выбранной БД: &1", stat-line(rs-status)).
             end.
          end.
          if rs-list-method = "loc-pg-codes" then do:
             if g#db-num = 0 then do:
               dsp-rs-option = substitute("Штучные коды для весов коды на выбранной БД: &1", stat-line(rs-status)).
             end.
          end.
          message dsp-rs-option
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error.
          end.
          if g#db-num = 0 then do:
            run adm/dbs.w ( INPUT parparentproc
                            ,INPUT {&LOOKUP}
                            ,OUTPUT v-rid) NO-ERROR.
            /*выбор БД*/
            if error-status:error or v-rid = ? then do:
              run UI-on.
              return error.
            end.
          end.
          else do:
             find first buf_db no-lock where buf_db.db-num = g#db-num.
             v-rid = recid(buf_db).
          end.
          define variable choice as integer no-undo .
          run gbl/d-askw.w (input "Вопрос",
                                input  ("На каждом объекте весовые товары взвешиваются" + {&new-line}
                                        + "с ипользованием определенного кода" + {&new-line}
                                        + "(Атрибут товара на объекте ВЕСОВОЙ КОД)" + {&new-line}
                                        + "Определите какие коды включать в выборку"
                                        ),
                                input "|",
                                input "Все|Используемые|НЕиспользуемые|Отменить",
                                input "Все|Взвешиваются c этим кодом|НЕ взвешиваются c этим кодом|Отменить",
                                input 1,
                                input 4,
                                output choice).
          if choice = 4
          then do:
            run UI-on.
            return error.
          end.
          /*вылруг когда-нибудь будет выбор нескольких БД*/
          v-recs = num-entries (string(v-rid)).
          do num-rec = 0 to v-recs:
            if num-rec > 0
            then do:
              v-ref-rec = integer (entry (num-rec, string(v-rid))).
              find buf_db where recid (buf_db) = integer(entry(num-rec, string(v-rid))) no-lock.
            end.
            if num-rec = 0 then do:
              case choice:
                when 1 then do:
                  assign
                  dsp-rs = dsp-rs-option
                  .
                end.
                when 2 then do:
                  assign
                  dsp-rs = substitute("&1 используемые для взвешивания", dsp-rs-option)
                  .
                end.
                when 3 then do:
                  assign
                  v-item_    = substitute("&1 НЕиспользуемые для взвешивания", dsp-rs-option)
                  .
                end.
              end case.
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = dsp-rs-option
              v-item_     = ""
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
            end.
            else do:
              case choice:
                when 1 then do:
                  assign
                  v-item_    = string(buf_db.db-num) + {&delim-key} + "all"
                  .
                end.
                when 2 then do:
                  assign
                  v-item_    = string(buf_db.db-num) + {&delim-key} + "using"
                  .
                end.
                when 3 then do:
                  assign
                  v-item_    = string(buf_db.db-num) + {&delim-key} + "nonusing"
                  .
                end.
              end case.
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs =  substitute("     БД &1", buf_db.db-num)
              v-tbl-name =  ''
              v-bh       = ?
              v-tot-lns = tot-lns + num-rec
              .
            end.
            v-no-hist = num-rec.
            run create-{1}-hist in this-procedure(input {&add-def}
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item_
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 then v-seq  = v-temp-seq.
          end. /*do num-rec*/
        end. /*when "loc-sc-codes"*/
        when "prod-bc-off":U then do:
          glog = yes.
          message "Все выключенные ДопБк"
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error.
          end.
          run create-{1}-hist in this-procedure (
                                                input {&add-def}
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input substitute("Все выключенные ДопБК")
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input 'prod-bc-off':U
                                              , input '':U
                                              , input ?
                                              ).
        end.
        when "scaner" then do:
          glog = yes.
          message "Все коды из файла, полученного с мобильного сканера."
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on.
            return error.
          end.
          system-dialog get-file f-gds-name
          title "Выберите файл со сканера"
          filters "WorkAbout MS15  *.dbs" "*.dbs",
                  "WorkAbout  *.imp" "*.imp",
                  "Инвентаризация касса  *.inv" "*.inv",
                  "Все файлы  *.*" "*.*"
            INITIAL-DIR "."
            return-to-start-dir
            must-exist
            /* use-filename */
            update glog
            default-extension "dbs".
          if not glog then do:
            run UI-on.
            return error.
          end.
          run create-{1}-hist in this-procedure(input {&add-def}
                                                , input-output v-seq
                                                , input 0
                                                , input '':U
                                                , input substitute("Файл сканера : &1 &2", f-name, stat-line(rs-status))
                                                , input tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input f-gds-name
                                                , input '':U
                                                , input ?
                                                ).
        end.
      when "filter" then do:
        glog = yes.
        message "Все баркоды, выбранные в соответствии с заданным фильтром (без учета сортировки)."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        assign
        tbl = 'bar-code'
        join-tbl = ','
        fld = ""
        lab = ""
        spr = ""
        dim = '0'
        c-point = "bb-list" + {&delim-par} + "Список кодов" + {&delim-par} + "no"
        .

        define variable v-flt-rec as recid no-undo .
        define variable v-filter-name as character no-undo .
        define variable where-phrase as character no-undo .
        define variable sort-phrase as character no-undo .
        define variable where-phrase-rus as character no-undo .
        define variable sort-phrase-rus as character no-undo .

        run fltfield-add in this-procedure('part-code', '№ партии', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('in-code', '№ ПН', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('cli-base-rate', 'Коэфф', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('unit-cli', 'Ед.изм.', 'unit',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


        run gbl/filter.w ( input parparentproc
                          ,input c-point
                          ,input tbl
                          ,input join-tbl
                          ,input fld
                          ,input lab
                          ,input spr
                          ,input dim).
        run gbl/flt-get.p (
                         input  c-point
                        ,output v-flt-rec
                        ,output v-filter-name
                        ,output where-phrase
                        ,output sort-phrase
                        ,output where-phrase-rus
                        ,output sort-phrase-rus  ).
        if v-flt-rec = ? then do:
          run UI-on in this-procedure.
          return error.
        end.
        else do:
          find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input substitute("Фильтр : &1 &2 &3", ubflt.filter.naim, ubflt.filter.where-ysl-rus, stat-line(rs-status))
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input ubflt.filter.where-ysl
                                              , input '':U
                                              , input ?
                                              ).
        end.
      end.
      otherwise do:
        message "Неизвестный" rs-list-method view-as alert-box .
      end.
     end CASE.
    if tot-lns <> 0 then do:
      run get-operation in this-procedure (input dsp-rs, output v-operation) no-error .
      CASE v-operation:
        when {&add-operation} then do:
          run proc-b-add in this-procedure(no, ?, rs-list-method, rs-status) no-error  .
        end.
        when {&del-operation} then do:
          run proc-b-del in this-procedure(no, ?, rs-list-method, rs-status ) no-error  .
        end.
        when {&rest-operation} then do:
          run proc-b-rest in this-procedure(no, ?, rs-list-method, rs-status) no-error  .
        end.
        otherwise do:
          assign
          dsp-rs = "":U.
          run UI-on.
          return error.
        end.
      END CASE.
      if error-status:error then do:
        run UI-on.
        return error return-value .
      end.
    end.
    assign
    rs-list-method = temp-list.fvalue
    .
    find last buf_{1}-hist no-lock where
              buf_{1}-hist.id = (v-seq - 1)
        and  buf_{1}-hist.line = 0 no-error .
    DISPLAY
    (if available buf_{1}-hist
    then buf_{1}-hist.des
    else '') @ dsp-rs
    with frame {&frame-name}.
    if tot-lns = 0
    then do:
      run proc-b-add in this-procedure(no, ?, rs-list-method, rs-status)  .
    end.
  end.
end.
end procedure. /* proc-vc-rs-list-method */



procedure proc-scn-tsd :

  do
  on error undo, return error
  :
&if "{1}" = "scnblist" &then
  assign
    f-name = "default.inv"
    glog = yes
    .
  system-dialog get-file f-name
    filters "Инвентаризация касса *.inv" "*.inv"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "inv".
  if not glog then do:
    apply "entry" to br-list in frame {&frame-name}.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Сохранение в формате мобильного сканера.    ЖДИТЕ...").
  output to value (f-name).
  for each {1}:
    if {1}.in-code = ""
    and ub.bar-code.part-code = "" then do:
      if {1}.qnty <> 0 then
      put unformatted string (ub.bar-code.b-code) + "," + string ({1}.qnty) skip.
    end.
  end.
  output close.
  run waitfram-hide in this-procedure .
&else
  run str/diallog.w (parparentproc
              , this-procedure
              , 'str/send-tsd.p':U
              , (p-curr-obj-type + {&delim-par} + string(p-curr-obj-code) + {&delim-par} + "bb-list":U)
              , no /*p-auto-go*/
              , '':U
              , 'Пересылка товаров на ТСД') no-error .

&endif
  end.
end procedure. /* proc-scn-tsd */


procedure proc-b-add :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .


  do
  on error undo, return error
  :
  line-mode = {&add-def}.
  if rs-list-method = "single" then do:
     v-no-hist = - 1.
    if p-from-macro then do:
    end.
    else do:
      assign
      frame {&frame-name}
      T-all-prt
      &if "{&ean-option}" <> "no" &then
      T-bc-alt
      T-bc-base
      &endif
      T-loc-alt
      T-loc-base
      &if "{&parts-option}" <> "no" &then
      T-parts-all
      T-parts-not-blank
      T-parts-ser
      &endif
      &if "{&pbc-option}" <> "no" &then
      T-pb-alt
      T-pb-base
      T-sc-base
      &endif
      .
      if (
      T-all-prt or
      T-bc-alt  or
      T-bc-base or
      T-loc-alt or
      T-loc-base  or
      T-parts-all  or
      T-parts-not-blank or
      T-parts-ser or
      T-pb-alt    or
      T-pb-base   or
      T-sc-base) = no then do:
        message
        "Не выбран ни один тип кодов!"
        view-as alert-box error .
        undo, return error .
      end.
      assign
      temp-shop.obj-code = p-curr-obj-code
      temp-shop.all-prt = T-all-prt
      temp-shop.cd-bc-alt = T-bc-alt
      temp-shop.cd-bc-base = T-bc-base
      temp-shop.cd-loc-alt = T-loc-alt
      temp-shop.cd-loc-base = T-loc-base
      temp-shop.cd-parts-all = T-parts-all
      temp-shop.cd-parts-not-blank = T-parts-not-blank
      temp-shop.cd-parts-ser = T-parts-ser
      temp-shop.cd-pb-alt = T-pb-alt
      temp-shop.cd-pb-base = T-pb-base
      temp-shop.cd-sc-base = T-sc-base
      .
    end.
    if p-from-macro then do:
      find ub.goods where rowid(ub.goods) = p-rowid no-lock no-error .
    end.
    else do:
      run ref/gds-ref.p ( input parparentproc
                      ,input "b-sel,b-add"
                      ,input ?               /*p-stat */
                      ,input ?               /*p-list  */
                      ,input ?               /*p-cond  */
                      ,input ?               /*p-rec   */
                      ,input ?               /*p-grp   */
                      ,input ?               /*p-cli-type */
                      ,input ?               /*p-cli-code  */
                      ,input p-curr-obj-type      /*p-obj-type  */
                      ,input p-curr-obj-code       /*p-obj-code  */
                      ,input ?               /*p-other     */
                      ,output ref-list).
      apply "entry" to br-list in frame {&frame-name}.
      if ref-list = "" then
        return no-apply.
      /* выбран товар */
      find goods where recid (goods) = integer (ref-list) no-lock no-error.
    end.
    if available goods then do:
      run process-one-good in this-procedure (input rs-list-method, input rs-status, input line-mode ,buffer goods) no-error .
      tot-lns = tot-lns + lns-cnt.
      run write-hist(p-from-macro, rs-list-method, rs-status, line-mode, buffer goods).
    end.
    else do:
      return error "Нет в БД такого товара".
    end.
    run UI-on.
  end.
  else
    run rs-do(no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
  end.

end procedure. /* proc-b-add */


procedure proc-b-del :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define variable v-rep-rec as recid no-undo .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.


  do
  on error undo, return error
  :
    line-mode = {&deletion}.
    if rs-list-method begins "single" then do:
     v-no-hist = - 1.
      if p-from-macro then do:
        CASE entry(2, rs-list-method, {&delim-par} ):
          when {&table_prod-bc} then do:
            find first buf_prod-bc where rowid(buf_prod-bc) = p-rowid no-error.
            if not available buf_prod-bc then return error "Нет в БД такого ДопБК".
            find first {1} where
                       {1}.b-code = buf_prod-bc.b-code
                   AND {1}.b-str = buf_prod-bc.b-str no-error.
          end.
          when {&table_bar-code}
          or
          when 'loc-ean':U then do:
            find first buf_bar-code where rowid(buf_bar-code) = p-rowid no-error.
            if not available buf_bar-code then return error "Нет в БД такого кода".
            find first {1} where
                       {1}.b-code = buf_bar-code.b-code
                   AND {1}.loc-ean = (if entry(2, rs-list-method, {&delim-par}) = {&table_bar-code} then no else yes) no-error.
          end.
        END CASE.
      end.
      if available {1} then do:
        line-rec = recid ({1}).
        get next br-list.
        if available {1} then v-rep-rec = recid ({1}).
        else do:
          reposition br-list to recid line-rec no-error.
          get prev br-list.
          if available {1} then v-rep-rec = recid ({1}).
        end.
        reposition br-list to recid line-rec no-error.
        tot-lns = tot-lns - 1.
        run write-hist(p-from-macro, rs-list-method, rs-status, line-mode, buffer ub.goods).
        delete {1}.
        line-rec = v-rep-rec.
        run UI-on.
      end.
      else do:
        return error "Нет в списке кодов такого кода".
      end.
    end.
    else do:
      glog = no.
      message "Удалить коды ПО заданному УСЛОВИЮ ?   Вы уверены ?"
              view-as alert-box question buttons OK-Cancel update glog.
      if not glog then  return error.
      run rs-do(no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
    end.
  end. /*doe*/

end procedure. /* proc-b-del */

procedure proc-b-rest :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define buffer buf_{1}-hist for {1}-hist.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.

  do
  on error undo, return error
  :
    line-mode = {&leave}.
    if rs-list-method begins "single" then do:
      v-no-hist = - 1.
      if p-from-macro then do:
        CASE entry(2, rs-list-method, {&delim-par} ):
          when {&table_prod-bc} then do:
            find first buf_prod-bc where rowid(buf_prod-bc) = p-rowid no-error.
            if not available buf_prod-bc then return error "Нет в БД такого ДопБК".
            find first {1} where
                       {1}.b-code = buf_prod-bc.b-code
                   AND {1}.b-str = buf_prod-bc.b-str no-error.
          end.
          when {&table_bar-code}
          or
          when 'loc-ean':U  then do:
            find first buf_bar-code where rowid(buf_bar-code) = p-rowid no-error.
            if not available buf_bar-code then return error "Нет в БД такого кода".
            find first {1} where
                       {1}.b-code = buf_bar-code.b-code
                   AND {1}.loc-ean = (if entry(2, rs-list-method, {&delim-par}) = {&table_bar-code} then no else yes) no-error.
          end.
        END CASE.
      end.
      if available {1} then do:
      if p-from-macro then do:
          glog = yes.
        end.
        else do:
          glog = no.
          message "Оставить отмеченную строку и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
                  view-as alert-box question buttons OK-Cancel update glog.
          if not glog then return error.
        end.
        line-rec = recid ({1}).
        v-seq = 1.
        for each buf_{1}-hist:
          delete buf_{1}-hist.
        end.
        run write-hist(p-from-macro, rs-list-method, rs-status, line-mode, buffer ub.goods).
        for each {1}:
          if line-rec <> recid ({1}) then delete {1}.
        end.
        tot-lns = 1.
        run UI-on.
      end.
    end.
    else do:
      glog = no.
      if not p-from-macro then do:
      message "Оставить коды ПО заданному УСЛОВИЮ и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
              view-as alert-box question buttons OK-Cancel update glog.
        if not glog then
        return no-apply.
      end.
      assign
      lns-cnt = 0
      lns-ignore = 0
      .
      run rs-do(no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
      for each {1}:
        if {1}.to-del = ? then do:
          assign
          {1}.to-del = no
          .
        end.
        else do:
          delete {1}.
        end.
      end.
      tot-lns = lns-cnt.
      run UI-on.
      message
      "Оставлено строк :" lns-cnt skip(0)
      string(if lns-ignore <> 0
      then ("Проигнорировано строк :" + string(lns-ignore))
      else "":U)
      .
    end.
  end. /*doe*/

end procedure. /* proc-b-rest */

procedure process-one-good :
define input  parameter rs-list-method as character no-undo .
define input  parameter rs-status as character no-undo .
define input  parameter line-mode as character no-undo .
define parameter buffer goods for ub.goods.


  do
  on error undo, return error
  :
      {&NEW-GOOD}
      run get-prt-and-unit in this-procedure (
                                               input ub.goods.prt-root
                                              ,input ub.goods.unit-base
                                              ,output l-empty-scale
                                              ) .
      FIND FIRST ub.gds-obj WHERE
                ub.gds-obj.obj-type = p-curr-obj-type AND
                ub.gds-obj.obj-code = p-curr-obj-code AND
                ub.gds-obj.artic = ub.goods.artic AND
                ub.gds-obj.prod-type = ub.goods.prod-type AND
                ub.gds-obj.prod-code = ub.goods.prod-code nO-LOCK NO-ERROR.
      if v-is-restaurant then do:
        find first buf_fbr-gds-obj no-lock where
                  buf_fbr-gds-obj.obj-type = p-curr-obj-type
              AND buf_fbr-gds-obj.obj-code = p-curr-obj-code
              AND buf_fbr-gds-obj.gds-code = ub.goods.gds-code no-error .
        if    available buf_fbr-gds-obj  
          and not buf_fbr-gds-obj.is-cd 
        then 
           NEXT.
      end.
      run get-gds-obj-fields in this-procedure(
                                                 buffer ub.gds-obj
                                                ,input no /*&find-option*/
                                                ,input ub.goods.gds-code
                                                ,input p-curr-obj-code
                                                ,input p-curr-obj-type
                                                ,output for-fact-qnty
                                                ,output cashparts
                                                ,output v-is-null-price
                                                ) no-error .
    RUN term-prt in this-procedure (
                  input rs-list-method
                , input rs-status
                , input line-mode
                , input ub.gds-prt.prt-root
                , input ?) no-error.

  end.

end procedure. /* process-one-good */

procedure get-gds-obj-fields :
define parameter buffer buf_gds-obj for ub.gds-obj .
define input parameter par-find-buffer as logical no-undo .
define input parameter par-gds-code like ub.goods.gds-code no-undo .
define input parameter par-obj-code like ub.clients.obj-code no-undo .
define input parameter par-obj-type like ub.clients.obj-type no-undo .
define output parameter par-fact-qnty like ub.gds-obj.fact-qnty no-undo .
define output parameter par-cash-parts as logical no-undo .
define output parameter p-is-null-price like ub.fbr-gds-obj.is-null-price  no-undo .


  do
  on error undo, return error
  :
    if par-find-buffer then do:
      find first buf_gds-obj no-lock where
                buf_gds-obj.gds-code = par-gds-code AND
                buf_gds-obj.obj-type = par-obj-type AND
                buf_gds-obj.obj-code = par-obj-code no-error .

    end.
    if not avail buf_gds-obj
    and (p-curr-obj-type = {&shop} and ub.shop.is-catering = no)
    then do:
      return.
    end.
    assign
    par-fact-qnty = (if available buf_gds-obj
                     then buf_gds-obj.fact-qnty
                     else 0)
    .
    assign
    par-cash-parts = (if available buf_gds-obj
                      then buf_gds-obj.cash-parts
                      else no)
    .
    if available buf_fbr-gds-obj then do:
      assign
      p-is-null-price     =  buf_fbr-gds-obj.is-null-price
      .
    end.
  end.

end procedure. /* get-gds-obj-fields */

procedure get-prt-and-unit :
define input parameter par-prt-root like ub.goods.prt-root no-undo .
define input parameter par-unit-base like ub.goods.unit-base no-undo .
define output parameter par-empty-scale as logical no-undo .

  do
  on error undo, return error
  :
    FIND FIRST ub.gds-prt where
               ub.gds-prt.upper-code = par-prt-root NO-LOCK .
    assign
    par-empty-scale =  NOT (v-doc-prt AND ( ub.gds-prt.node-name <> {&empty-scale}))
    .
    FIND FIRST ub.units WHERE
               ub.units.unit-name = par-unit-base NO-LOCK .

  end.

end procedure. /* get-prt-and-unit */
procedure proc-b-cd :
define input parameter p-fill-temp-shop as logical no-undo .

  do
  on error undo, return error
  :
  if available ub.shop then do:
    assign
    temp-shop.obj-code =    ub.shop.obj-code
    t-all-prt         =    ub.shop.all-prt
    &if "{&ean-option}" <> "no" &then
    t-bc-alt          =    ub.shop.cd-bc-alt
    t-bc-base         =    ub.shop.cd-bc-base
    &endif
    t-loc-alt         =    ub.shop.cd-loc-alt
    t-loc-base        =    ub.shop.cd-loc-base
    &if "{&parts-option}" <> "no" &then
    t-parts-all       =    ub.shop.cd-parts-all
    t-parts-not-blank =    ub.shop.cd-parts-not-blank
    t-parts-ser       =    ub.shop.cd-parts-ser
    &endif
    &if "{&pbc-option}" <> "no" &then
    t-pb-alt          =    ub.shop.cd-pb-alt
    t-pb-base         =    ub.shop.cd-pb-base
    t-sc-base         =    ub.shop.cd-sc-base
    &endif
    .
    if (t-all-prt or
    t-bc-alt     or
    t-bc-base    or
    t-loc-alt    or
    t-loc-base   or
    t-parts-all  or
    t-parts-not-blank or
    t-parts-ser       or
    t-pb-alt          or
    t-pb-base         or
    t-sc-base ) = no then do:
      message
      substitute("Для магазина &1 не выбран ни один тип кодов, выбираем основные локальные&2"  +
                 "Иначе список формировать бесполезно"
                 , shop.obj-code
                 , {&new-line})
      view-as alert-box warning.
      t-loc-base = yes.
    end.
    if p-fill-temp-shop then do:
      assign
      temp-shop.obj-code = p-curr-obj-code
      temp-shop.all-prt = T-all-prt
      temp-shop.cd-bc-alt = T-bc-alt
      temp-shop.cd-bc-base = T-bc-base
      temp-shop.cd-loc-alt = T-loc-alt
      temp-shop.cd-loc-base = T-loc-base
      temp-shop.cd-parts-all = T-parts-all
      temp-shop.cd-parts-not-blank = T-parts-not-blank
      temp-shop.cd-parts-ser = T-parts-ser
      temp-shop.cd-pb-alt = T-pb-alt
      temp-shop.cd-pb-base = T-pb-base
      temp-shop.cd-sc-base = T-sc-base
      .
    end.
  end.
  else do:
    assign
    temp-shop.obj-code =  ub.store.obj-code
    t-loc-base         =   yes
    t-all-prt          = no
    t-bc-alt           = no
    t-bc-base          = no
    t-loc-alt          = no
    t-parts-all        = no
    t-parts-not-blank  = no
    t-parts-ser        = no
    t-pb-alt           = no
    t-pb-base          = no
    t-sc-base          = no
    .
    if p-fill-temp-shop then do:
      assign
      temp-shop.obj-code = p-curr-obj-code
      temp-shop.all-prt = T-all-prt
      temp-shop.cd-bc-alt = T-bc-alt
      temp-shop.cd-bc-base = T-bc-base
      temp-shop.cd-loc-alt = T-loc-alt
      temp-shop.cd-loc-base = T-loc-base
      temp-shop.cd-parts-all = T-parts-all
      temp-shop.cd-parts-not-blank = T-parts-not-blank
      temp-shop.cd-parts-ser = T-parts-ser
      temp-shop.cd-pb-alt = T-pb-alt
      temp-shop.cd-pb-base = T-pb-base
      temp-shop.cd-sc-base = T-sc-base
      .
    end.
  end.
    display
    T-loc-base
    T-pb-base
    T-loc-alt
    T-pb-alt
    T-bc-base
    T-sc-base
    T-bc-alt
    T-all-prt
    T-parts-ser
    T-parts-not-blank
    T-parts-all
    with frame {&frame-name}.
  run proc-cd2 in this-procedure .
  end.
end procedure. /* proc-b-cd */

procedure proc-cd2 :
define variable v-fvalue as character no-undo .

  do
  on error undo, return error
  :
    if available temp-list then v-fvalue = temp-list.fvalue.
    CASE v-fvalue:
      when "all"
      or
      when "goods"
      or
      when "gds-list"
      or
      when "file-gds" then do:
        ENABLE
        T-loc-base
        T-loc-alt
        &if "{&ean-option}" <> "no" &then
        T-bc-base
        T-bc-alt
        &endif
        T-all-prt
        &if "{&parts-option}" <> "no" &then
        T-parts-ser
        T-parts-not-blank
        T-parts-all
        &endif
        &if "{&pbc-option}" <> "no" &then
        T-pb-base
        T-pb-alt
        T-sc-base
        &endif
        WITH FRAME {&frame-name}.
      end.
      otherwise do:
        disable
        T-loc-base
        T-loc-alt
        &if "{&ean-option}" <> "no" &then
        T-bc-base
        T-bc-alt
        &endif
        T-all-prt
        &if "{&parts-option}" <> "no" &then
        T-parts-ser
        T-parts-not-blank
        T-parts-all
        &endif
        &if "{&pbc-option}" <> "no" &then
        T-pb-base
        T-pb-alt
        T-sc-base
        &endif
        WITH FRAME {&frame-name}.
      end.
    END CASE.
  end.

end procedure. /* proc-cd2 */

procedure proc-b-optimize :
define input  parameter p-from-macro as logical   no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter p-option as character no-undo .

define variable v-cnt as integer   no-undo .
define variable v-temp-seq as integer   no-undo .
define variable l-prod-bc-petrolium as logical no-undo .
define variable l-prod-bc-weight as logical no-undo .
define buffer b-str_bb-list for {1}.
define buffer b-code_bb-list for {1}.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_{1}-hist for {1}-hist.

  do
  on error undo, return error
  :
    /*output stream slog to optimize.log.*/

    case p-option:
      when "delnprod-bc" then  do:
        for each b-str_bb-list no-lock :
          if b-str_bb-list.b-str <> "":U
          and b-str_bb-list.loc-ean  = no
          then do:
            for each b-code_bb-list where
                       b-code_bb-list.b-code = b-str_bb-list.b-code
                  AND  (b-code_bb-list.b-str = "":U
                        or
                        b-code_bb-list.loc-ean = yes)
                  :
              delete b-code_bb-list.
              v-cnt = v-cnt + 1.
              /*
              put stream slog unformatted
              substitute("Удаляется бар-код &1 - есть ДопБК &2", b-str_bb-list.b-code, b-str_bb-list.b-str) skip.
              */
            end. /*for each b-code_bb-list where*/
          end. /*if b-str_bb-list.b-str <> "":U*/
        end. /*for each b-str_bb-list no-lock :*/
      end. /*      when "delnprod-bc" then  do:*/
      when "repnprod-bc" then  do:
        for each b-code_bb-list :
          if b-code_bb-list.b-str =  '':U
          or b-code_bb-list.loc-ean = yes then do:
            find first buf_prod-bc no-lock where
                      buf_prod-bc.b-code = b-code_bb-list.b-code
                  AND buf_prod-bc.bc-on = yes no-error.
            if available buf_prod-bc then do:
              /*проверим есть ли он в нашем списке*/
              find first b-str_bb-list no-lock where
                         b-str_bb-list.b-code = buf_prod-bc.b-code
                    AND  b-str_bb-list.b-str = buf_prod-bc.b-str no-error .
              if available b-str_bb-list then next.

              assign
              l-prod-bc-petrolium = no
              l-prod-bc-weight = no
              .
              /*проверим что это не весовой и не петрол*/
              { gbl/prodbcat.i
                buf_prod-bc
                "'weight=request':u"
                l-prod-bc-weight
                no-error
              }
              if error-status:error
              or l-prod-bc-weight then next.

              { gbl/prodbcat.i
                buf_prod-bc
                "'petrolium=request':u"
                l-prod-bc-petrolium
                no-error
              }
              if error-status:error
              or l-prod-bc-petrolium then next.


              find first buf_bar-code no-lock where
                          buf_bar-code.b-code = buf_prod-bc.b-code no-error.
              if available buf_bar-code then do:
                find first ub.goods no-lock where
                          ub.goods.gds-code = buf_bar-code.gds-code no-error.
                if available goods then do:
                  run get-prt-and-unit in this-procedure (
                                                          input ub.goods.prt-root
                                                          ,input ub.goods.unit-base
                                                          ,output l-empty-scale
                                                          ) .

                  delete b-code_bb-list.
                  v-cnt = v-cnt + 1.
                  run ex-bbc in this-procedure (input rs-list-method, input rs-status, input line-mode , input no, input "":U, input no, buffer buf_bar-code, buffer buf_prod-bc).
                  /*
                  put stream slog unformatted
                  substitute("Замещеается бар-код &1 на ДопБК &2", buf_prod-bc.b-code, buf_prod-bc.b-str) skip.
                  */
                end.
              end. /*if available buf_prod-bc then do:*/
            end. /*if available buf_prod-bc then do:*/
          end. /* if b-code_bb-list.b-str =  '':U*/
        end. /*for each b-code_bb-list :*/
      end. /*when "repnprod-bc" then  do:*/
    end case.
    /*output stream slog close.*/
    lns-cnt = lns-cnt - v-cnt.
  end.

end procedure. /* proc-b-optimize */

procedure proc-b-obj :
  define input parameter p-mode as character no-undo .

  define variable v-rid-list as character no-undo .

  define buffer buf_clients  for ub.clients.
  define buffer buf_user-obj for ub.user-obj.

  do
  on error undo, return error
  :
    find first buf_user-obj no-lock where
               buf_user-obj.user-id = v-cntxt-userid
           and buf_user-obj.db-num = v-cntxt-db-num
           and buf_user-obj.obj-type  = p-curr-obj-type
           and buf_user-obj.obj-code  = p-curr-obj-code no-error .
    assign
      v-rid-list = ( if available buf_user-obj then string( recid( buf_user-obj ) ) else "":U )
    .
    if p-mode = "change":U then do:
      { gbl/uobjsone.i
          parparentproc
          v-cntxt-db-num
          v-cntxt-userid
          v-cntxt-host-code-obj
          v-cntxt-obj-type
          v-cntxt-obj-code
          v-user-select
          v-sel-obj-type
          v-sel-obj-code
        }
      if v-user-select then do:
        FIND FIRST buf_user-obj NO-LOCK WHERE
                  buf_user-obj.obj-type = buf_user-obj.obj-type
            and buf_user-obj.obj-code = buf_user-obj.obj-code
            and buf_user-obj.db-num = v-cntxt-db-num
            and buf_user-obj.user-id = v-cntxt-userid    NO-ERROR.
        if not available buf_user-obj then do: return no-apply. end.
        find first buf_clients no-lock where
                  buf_clients.obj-type = buf_user-obj.obj-type
              and buf_clients.obj-code = buf_user-obj.obj-code no-error.
        if not available buf_clients then do: return error. end.
        assign
          p-curr-obj-type = buf_clients.obj-type
          p-curr-obj-code = buf_clients.obj-code
          v-host-code = buf_clients.host-code
          v-obj-type = buf_clients.obj-type
          v-obj-code = buf_clients.obj-code
          v-obj-name = buf_clients.obj-name
        .
        display
        v-obj-name
        v-obj-type
        v-obj-code
        with frame {&frame-name}.
      end.
    end.
  end.

end procedure. /* proc-b-obj */

procedure restore-codes :
define input  parameter p-codes as character no-undo .
define input  parameter p-obj-type like ub.clients.obj-type no-undo .
define input  parameter p-obj-code like ub.clients.obj-code no-undo .

  do
  on error undo, return error return-value
  :
    if p-obj-type = {&shop} then do:
    assign
    temp-shop.obj-code =   p-obj-code
    t-all-prt         =    lookup('all-prt':U, p-codes, {&space-char} ) > 0
    &if "{&ean-option}" <> "no" &then
    t-bc-alt          =    lookup('bc-alt':U, p-codes, {&space-char} ) > 0
    t-bc-base         =    lookup('bc-base':U, p-codes, {&space-char} ) > 0
    &else
    t-bc-alt          =    no
    t-bc-base         =    no
    &endif
    t-loc-alt         =    lookup('loc-alt':U, p-codes, {&space-char} ) > 0
    t-loc-base        =    lookup('loc-base':U, p-codes, {&space-char} ) > 0
    &if "{&parts-option}" <> "no" &then
    t-parts-all       =    lookup('parts-all':U, p-codes, {&space-char} ) > 0
    t-parts-not-blank =    lookup('parts-not-blank':U, p-codes, {&space-char} ) > 0
    t-parts-ser       =    lookup('parts-ser':U, p-codes, {&space-char} ) > 0
    &else
    t-parts-all       =    no
    t-parts-not-blank =    no
    t-parts-ser       =    no
    &endif
    &if "{&pbc-option}" <> "no" &then
    t-pb-alt          =    lookup('pb-alt':U, p-codes, {&space-char} ) > 0
    t-pb-base         =    lookup('pb-base':U, p-codes, {&space-char} ) > 0
    t-sc-base         =    lookup('sc-base':U, p-codes, {&space-char} ) > 0
    &else
    t-pb-alt = no
    t-pb-base = no
    t-sc-base = no
    &endif
    temp-shop.all-prt         =    lookup('all-prt':U, p-codes, {&space-char} ) > 0
    &if "{&ean-option}" <> "no" &then
    temp-shop.cd-bc-alt          =    lookup('bc-alt':U, p-codes, {&space-char} ) > 0
    temp-shop.cd-bc-base         =    lookup('bc-base':U, p-codes, {&space-char} ) > 0
    &else
    temp-shop.cd-bc-alt          =    no
    temp-shop.cd-bc-base         =    no
    &endif
    temp-shop.cd-loc-alt         =    lookup('loc-alt':U, p-codes, {&space-char} ) > 0
    temp-shop.cd-loc-base        =    lookup('loc-base':U, p-codes, {&space-char} ) > 0
    &if "{&parts-option}" <> "no" &then
    temp-shop.cd-parts-all       =    lookup('parts-all':U, p-codes, {&space-char} ) > 0
    temp-shop.cd-parts-not-blank =    lookup('parts-not-blank':U, p-codes, {&space-char} ) > 0
    temp-shop.cd-parts-ser       =    lookup('parts-ser':U, p-codes, {&space-char} ) > 0
    &else
    temp-shop.cd-parts-all       =    no
    temp-shop.cd-parts-not-blank =    no
    temp-shop.cd-parts-ser       =    no
    &endif
    &if "{&pbc-option}" <> "no" &then
    temp-shop.cd-pb-alt          =    lookup('pb-alt':U, p-codes, {&space-char} ) > 0
    temp-shop.cd-pb-base         =    lookup('pb-base':U, p-codes, {&space-char} ) > 0
    temp-shop.cd-sc-base         =    lookup('sc-base':U, p-codes, {&space-char} ) > 0
    &else
    temp-shop.cd-pb-alt          =    no
    temp-shop.cd-pb-base         =    no
    temp-shop.cd-sc-base         =    no
    &endif
    .

    display
    T-loc-base
    T-pb-base
    T-loc-alt
    T-pb-alt
    T-bc-base
    T-sc-base
    T-bc-alt
    T-all-prt
    T-parts-ser
    T-parts-not-blank
    T-parts-all
    with frame {&frame-name}.
  end.
  run proc-cd2 in this-procedure .
  end.

end procedure. /* restore-codes */

procedure proc-macros :
define variable glog as logical no-undo .
define variable v-option as integer no-undo .
define buffer buf_{1}-hist for {1}-hist.
define buffer buf_macro-list-hist for macro-list-hist.
if can-find(first macro-list-hist) then do:
  run gbl/d-askw.w ( input "Сохранение макроса"
                ,input "Выберите какие действия по формированию списка Вы хотите сохранить"
                ,input "|"
                ,input "Посл.ЗАПИСЬ|Все|Отказ"
                ,input "Действия при нажатой кнопке ЗАПИСЬ|ВСЯ последовательность действий|Отказ"
                ,input 1
                ,input 3
                ,output v-option).
  if v-option = 3 then return no-apply.
  v-option = 1.
end.
else do:
  message
  "Будет сохранена в файл ВСЯ последовательность действий по формированию списка" skip
  view-as alert-box question buttons yes-no update glog.
  v-option = 2.
  if not glog then do:
    return no-apply.
  end.
end.
  do
  on error undo, return error
  :
  assign
    f-name = "default.bbm"
    glog = yes
    .
  system-dialog get-file f-name
    filters "Макрос создания списка кодов *.bbm" "*.bbm"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "bbm".
  if not glog then do:
    apply "entry" to br-list in frame {&frame-name}.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Сохранение макроса формирования списка кодов.    ЖДИТЕ...").
  output stream PrnLibStream to value (f-name).
  case v-option:
    when 1 then do:
      for each buf_macro-list-hist:
        export stream PrnLibStream
        buf_macro-list-hist.
      end.
    end.
    when 2 then do:
  for each buf_{1}-hist:
      export stream PrnLibStream
      buf_{1}-hist.
  end.
    end.
  end case.

  output stream PrnLibStream close.
  run waitfram-hide in this-procedure .
  end.
end procedure. /* proc-macros */

PROCEDURE reposition-goods :
define input  parameter p-direction   as character no-undo .
define output parameter p-recid as recid no-undo .
/* перемещение на первую, последнюю, предыдущую, следующую */
define buffer buf_goods for ub.goods.
case p-direction :
  when "first":U
  then do:
    get first br-list.
  end.
  when "last":U
  then do:
    get last br-list.
  end.
  when "prev":U
  then do:
    get prev br-list.
    if not available {1} then do:
      message
      "Это первый товар списка"
      view-as alert-box.
    end.
  end.
  when "next":U
  then do:
    get next br-list.
    if not available {1} then do:
      message
      "Это последний товар списка"
      view-as alert-box.
    end.
  end.
end case . /* p-direction */
find first buf_goods no-lock where
        buf_goods.gds-code = {1}.gds-code no-error.
if available {1} then do:
  assign
  p-recid = recid(buf_goods)
  .
end.
run reposition-query in this-procedure
  (input recid({1})
  ).
END PROCEDURE.

PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .

if p-recid <> ?
then do:
  reposition br-list to recid p-recid no-error.
end.

do with frame {&frame-name}:
  apply "entry":u to browse {&browse-name} .
  apply "VALUE-CHANGED":u to browse {&browse-name} .
end. /* do with frame */

END PROCEDURE.

procedure proc-cd :
define variable v-num as integer no-undo .
define variable v-action as character no-undo .
define buffer buf_bb-list for {1}.
if p-curr-obj-type <> {&shop} then return.
run gbl/d-askw.w (
                  input "Отослать на кассы"
                 ,input "Передача/удаление списка кодов на кассу/с кассы"
                 ,input "|"
                 ,input "Передача|Удаление|Отмена"
                 ,input "Передача на кассу|Удаление с кассы|Отмена"
                 ,input 1
                 ,input 3
                 ,output v-num).
if v-num = 3 then return.
v-action = (if v-num = 1 then "U":U else "D").
define variable v-chk-act-host-code as integer   no-undo .
define variable v-ok as logical no-undo .
{ gbl/hostcode.i
  {&shop}
  abs(p-curr-obj-code)
  v-chk-act-host-code
}
if v-action = "U" then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-goods_add-def':U
    {&cntxt-object}
    v-chk-act-host-code
    {&shop}
    abs(p-curr-obj-code)
    0
    0
    0
    true
    v-ok
  }
end.
else do:
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_cashdesk-goods_deletion':U
  {&cntxt-object}
  v-chk-act-host-code
  {&shop}
  abs(p-curr-obj-code)
  0
  0
  0
  true
  v-ok
}
end.
if NOT v-ok then return .
/*
преобразование bb-list в bc-list  и pbc-list
*/
for each bc-list:
  delete bc-list.
end.
for each pbc-list:
  delete pbc-list.
end.
for each buf_bb-list:
  if buf_bb-list.b-str <> ""
  and buf_bb-list.loc-ean = no
  then do:
    create pbc-list.
    buffer-copy buf_bb-list to pbc-list.
    if v-action = "D" then do:
      assign
      pbc-list.del = yes.
    end.
    release pbc-list.
  end.
  else do:
    find first bc-list where
              bc-list.b-code = buf_bb-list.b-code no-error.
    if not available bc-list then do:
    create bc-list.
    buffer-copy buf_bb-list to bc-list.
      if v-action = "D" then do:
        assign
        bc-list.del = yes.
      end.
    release bc-list.
    end.
  end.
end.
if can-find(first bc-list no-lock) then do:
    run str/diallog.w ( input parparentproc
                  , input this-procedure
                  , input 'str/send-bcn.p':U
                  , input (string(p-curr-obj-code) + {&delim-par} + v-action)
                  , input (if can-find(first pbc-list no-lock)
                           then yes
                           else no) /*p-auto-go*/
                  , input 'Прервать'
                  , input (if v-action = "U"
                           then 'Отсылка бар-кодов на кассу'
                           else 'Удаление бар-кодов c кассы'
                           )) no-error .
end.
if can-find(first pbc-list no-lock) then do:
    run str/diallog.w ( input parparentproc
                  , input this-procedure
                  , input 'str/s-prdbcn.p':U
                  , input (string(p-curr-obj-code) + {&delim-par} + v-action)
                  , input no /*p-auto-go*/
                  , input 'Прервать'
                  , input (if v-action = "U"
                           then 'Отсылка ДопБК на кассу'
                           else 'Удаление ДопБК с кассы'
                           )) no-error .

end.
end procedure. /* proc-cd */

PROCEDURE proc-parts-cashparts :
define input parameter rs-list-method as character no-undo .
define variable v-value-integer as integer   no-undo .
define variable glog as logical no-undo .
define variable v-message as character no-undo .
define variable v-item as character no-undo .
assign
frame {&frame-name}
t-parts-not-blank
t-parts-all
.

if not (t-parts-not-blank or t-parts-all ) then do:
  message
  "У Вас не включен флаг <на непуст. № парт.> ИЛИ <все партии>" skip
  "Вы уверены, что Вам нужны коды ПАРТИЙ?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then do:
    undo, return error .
  end.
end.


glog = yes.
CASE rs-list-method:
  when "parts-cashparts":U then do:
    assign
    v-message = substitute("Лок.коды партий свободной зоны &1&2 для товаров с продажей по партиям", {&new-line}, stat-line(rs-status))
    .
  end.
  when "parts-ean-cashparts":U then do:
    assign
    v-message = substitute("Лок.коды (EAN) партий свободной зоны &1&2 для товаров с продажей по партиям", {&new-line}, stat-line(rs-status))
    .
  end.
END CASE.
message
v-message
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
    v-sel-obj-type
    v-sel-obj-code
  }
if not v-user-select then do:
  return error.
end.

CASE rs-list-method:
  when "parts-cashparts":U then do:
    assign
    dsp-rs = substitute("Лок.коды партий свободной зоны на &1&2 для товаров с продажей по партиям &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code)
    .
  end.
  when "parts-ean-cashparts":U then do:
    assign
    dsp-rs = substitute("Лок.коды (EAN) партий свободной зоны на &1&2 для товаров с продажей по партиям &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code)
    .
  end.

END CASE.
v-no-hist = 0.
run create-{1}-hist in this-procedure(input {&add-def}
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-item
                                    , input '':U
                                    , input ?
                                    ).

END PROCEDURE.




PROCEDURE proc-parts-last-date :
define input parameter rs-list-method as character no-undo .
define variable v-value-integer as integer   no-undo .
define variable glog as logical no-undo .
define variable v-message as character no-undo .
define variable v-item as character no-undo .
assign
frame {&frame-name}
t-parts-not-blank
t-parts-all
.

if not (t-parts-not-blank or t-parts-all ) then do:
  message
  "У Вас не включен флаг <на непуст. № парт.> ИЛИ <все партии>" skip
  "Вы уверены, что Вам нужны коды ПАРТИЙ?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then do:
    undo, return error .
  end.
end.


glog = yes.
CASE rs-list-method:
  when "parts-last-date":U then do:
    assign
    v-message = substitute("Лок.коды партий свободной зоны &1&2 с истекающим сроком хранения", {&new-line}, stat-line(rs-status))
    .
  end.
  when "parts-rsrv-last-date":U then do:
    assign
    v-message = substitute("Лок.коды зарезерв.партий &1&2 с истекающим сроком хранения", {&new-line}, stat-line(rs-status))
    .
  end.
  when "parts-ean-last-date":U then do:
    assign
    v-message = substitute("Лок.коды (EAN) партий свободной зоны &1&2 с истекающим сроком хранения", {&new-line}, stat-line(rs-status))
    .
  end.
  when "parts-ean-rsrv-last-date":U then do:
    assign
    v-message = substitute("Лок.коды (EAN) зарезерв.партий &1&2 с истекающим сроком хранения", {&new-line}, stat-line(rs-status))
    .
  end.

END CASE.
message
v-message
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
    v-sel-obj-type
    v-sel-obj-code
  }
if not v-user-select then do:
  return error.
end.
run gbl/d-integer.w (
        input ?
      ,input (
      'title=':u + substitute("Введите кол-во дней, в течение которых истекает срок хранения") + '\':u
    + 'text1=':u + "Кол-во дней" + '\':u
    + 'format=' + "->>9" + '\':u
    + 'fillin_row=3\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=' +  'no':u + '\':u)
    , input-output v-value-integer
    , output v-ok
        ).
if not v-ok then return error.

CASE rs-list-method:
  when "parts-last-date":U then do:
    assign
    dsp-rs = substitute("Лок.коды партий свободной зоны на &1&2 со сроком хранения, истекающим через &3 дн.  и ранее &4", v-sel-obj-type, v-sel-obj-code, v-value-integer, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code)  + {&delim-key} + string(v-value-integer)
    .
  end.
  when "parts-rsrv-last-date":U then do:
    assign
    dsp-rs = substitute("Лок.коды зарезерв. партий на &1&2 со сроком хранения, истекающим через &3 дн.  и ранее &4", v-sel-obj-type, v-sel-obj-code, v-value-integer, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code)  + {&delim-key} + string(v-value-integer)
    .
  end.
  when "parts-ean-last-date":U then do:
    assign
    dsp-rs = substitute("Лок.коды (EAN) партий свободной зоны на &1&2 со сроком хранения, истекающим через &3 дн.  и ранее &4", v-sel-obj-type, v-sel-obj-code, v-value-integer, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code)  + {&delim-key} + string(v-value-integer)
    .
  end.
  when "parts-ean-rsrv-last-date":U then do:
    assign
    dsp-rs = substitute("Лок.коды (EAN) зарезерв. партий на &1&2 со сроком хранения, истекающим через &3 дн.  и ранее &4", v-sel-obj-type, v-sel-obj-code, v-value-integer, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code)  + {&delim-key} + string(v-value-integer)
    .
  end.

END CASE.
v-no-hist = 0.
run create-{1}-hist in this-procedure(input {&add-def}
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-item
                                    , input '':U
                                    , input ?
                                    ).

END PROCEDURE.

PROCEDURE proc-parts-fib :
define input parameter rs-list-method as character no-undo .
define variable v-value-integer as integer   no-undo .
define variable glog as logical no-undo .
define variable v-message as character no-undo .
define variable v-item as character no-undo .
assign
frame {&frame-name}
t-parts-not-blank
t-parts-all
.

if not (t-parts-not-blank or t-parts-all ) then do:
  message
  "У Вас не включен флаг <на непуст. № парт.> ИЛИ <все партии>" skip
  "Вы уверены, что Вам нужны коды ПАРТИЙ?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then do:
    undo, return error .
  end.
end.


glog = yes.
CASE rs-list-method:
  when "parts-fib":U then do:
    assign
    v-message = substitute("Лок.коды ФиБ партий свободной зоны &1&2", {&new-line}, stat-line(rs-status))
    .
  end.
  when "parts-rsrv-fib":U then do:
    assign
    v-message = substitute("Лок.коды зарезерв. ФиБ партий &1&2", {&new-line}, stat-line(rs-status))
    .
  end.
  when "parts-ean-fib":U then do:
    assign
    v-message = substitute("Лок.коды (EAN) ФиБ партий свободной зоны &1&2", {&new-line}, stat-line(rs-status))
    .
  end.
  when "parts-ean-rsrv-fib":U then do:
    assign
    v-message = substitute("Лок.коды (EAN) зарезерв.ФиБ партий &1&2", {&new-line}, stat-line(rs-status))
    .
  end.

END CASE.
message
v-message
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
    v-sel-obj-type
    v-sel-obj-code
  }
if not v-user-select then do:
  return error.
end.
CASE rs-list-method:
  when "parts-fib":U then do:
    assign
    dsp-rs = substitute("Лок.коды ФиБ партий свободной зоны на &1&2 &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code)
    .
  end.
  when "parts-rsrv-fib":U then do:
    assign
    dsp-rs = substitute("Лок.коды зарезерв. ФиБ партий на &1&2 &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code)
    .
  end.
  when "parts-ean-fib":U then do:
    assign
    dsp-rs = substitute("Лок.коды (EAN) ФиБ партий свободной зоны на &1&2 &4", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code)
    .
  end.
  when "parts-ean-rsrv-fib":U then do:
    assign
    dsp-rs = substitute("Лок.коды (EAN) зарезерв. ФиБ партий на &1&2 &4", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code)
    .
  end.

END CASE.
v-no-hist = 0.
run create-{1}-hist in this-procedure(input {&add-def}
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-item
                                    , input '':U
                                    , input ?
                                    ).

END PROCEDURE.

PROCEDURE proc-parts-end :
define input parameter rs-list-method as character no-undo .
define variable v-value-integer as integer   no-undo .
define variable glog as logical no-undo .
define variable v-message as character no-undo .
define variable v-item as character no-undo .
define variable v-from-date as date no-undo .
define variable v-to-date as date no-undo .
define buffer buf_rp-by-call for ub.rp-by-call.
find first buf_rp-by-call no-lock where
          buf_rp-by-call.profile_id = 62 no-error.
if not available buf_rp-by-call then do:
  message
  "В вашей системе НЕ ВКЛЮЧЕН профайл установки флагов на закончившиеся партии" skip

  "Отбор невозможен"
  view-as alert-box error .
  return error.
end.
assign
frame {&frame-name}
t-parts-not-blank
t-parts-all
.

if not (t-parts-not-blank or t-parts-all ) then do:
  message
  "У Вас не включен флаг <на непуст. № парт.> ИЛИ <все партии>" skip
  "Вы уверены, что Вам нужны коды ПАРТИЙ?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then do:
    undo, return error .
  end.
end.
glog = yes.
CASE rs-list-method:
  when "parts-end-date-obj":U then do:
    assign
    v-message = substitute("Лок.коды закончившихся партий по объекту &1&2", {&new-line}, stat-line(rs-status))
    .
  end.
  when "parts-ean-end-date-obj":U then do:
    assign
    v-message = substitute("Лок.коды (EAN) закончившихся партий по объекту &1&2", {&new-line}, stat-line(rs-status))
    .
  end.
END CASE.
message
v-message
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
    v-sel-obj-type
    v-sel-obj-code
  }
if not v-user-select then do:
  return error.
end.
message
"Выберите начальную и конечную даты, между которыми было обнаружено, что партия закончилась"
view-as alert-box.
run gbl/get-per.w ( output glog
                   ,input-output v-from-date
                   ,input-output v-to-date
                   ) no-error.

CASE rs-list-method:
  when "parts-end-date-obj":U then do:
    assign
    dsp-rs = substitute("Лок.коды закончившихся партий на &1&2 &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} +
             string(v-sel-obj-code) + {&delim-key} +
             string(v-from-date, "99/99/9999") + {&delim-key} +
             string(v-to-date, "99/99/9999")
    .
  end.
  when "parts-ean-end-date-obj":U then do:
    assign
    dsp-rs = substitute("Лок.коды (EAN) закончившихся партий на &1&2 &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} +
             string(v-sel-obj-code) + {&delim-key} +
             string(v-from-date, "99/99/9999") + {&delim-key} +
             string(v-to-date, "99/99/9999")
    .
  end.
END CASE.
v-no-hist = 0.
run create-{1}-hist in this-procedure(input {&add-def}
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-item
                                    , input '':U
                                    , input ?
                                    ).

END PROCEDURE.