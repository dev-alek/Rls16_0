/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматизированное формирование списка товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/19/05
Author: Bakhtadze Natalya
Creation date: 09/19/05

Author: Исаков Андрей Валерьевич
Created: 06.06.95

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Автоматизированное формирование списка товаров".
{ cmp/vssrevis.i }
{ str/cont-ms-def.i }


&if "{1}" <> "gds-list" and "{1}" <> "scn-list"  and "{1}" <> "gds-list-flt" &then
&message any-list.i можно вызывать только для таблицы gds-list или таблиц scn-list gds-list-flt
&endif

&scop add-operation 1
&scop del-operation 2
&scop rest-operation 3
&scop cancel-operation 4

&scop browse-name br-list

&scop FRAME-NAME     Dialog-Frame
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
  else display f-tot-lns with frame ~{&frame-name~}.
&scop OPEN-BR-option open query br-option for each temp-list no-lock .

&scop all-options                                 ~
"Текущая строка,single,                           ~
Товар,goods,                                      ~
Товар ТСД,tsd,                                      ~
Товар-объект,gds-obj,                             ~
Товар-объект-факт,gds-obj-fact,                   ~
Товар-объект-своб,gds-obj-free,                   ~
Файл,file,                                        ~
Хранимый в БД список,clob-data,                     ~
Фильтр,filter,                                    ~
Все,all,                                          ~
Группа товаров,gds-grp,                           ~
Производитель,producer,                           ~
Группа пр-лей,grp-prod,                           ~
Поставщик,supplier,                               ~
Группа пост-ков,grp-supp,                         ~
Объект,object,                                    ~
В наличии,available,                              ~
Переоценка,overvalue,                             ~
ДНЦ,pdf,                                          ~
Документ,waybill,                                 ~
Производство,manufacture,                         ~
Товары Рецепта,recipe,                            ~
Рецепта,self-recipe,                              ~
Контрагент,client,                                ~
Консигнант,consignee,                             ~
Договор,contract,                                 ~
Отриц. остатки,neg-rest,                          ~
Отриц. партии все,neg-part,                       ~
Отриц. партии своб.,neg-part-free,                ~
Отриц. признаки,neg-prt,                          ~
Нулев. остатки,nul-rest,                          ~
Топливо,is-ptrl,                                  ~
Услуга,gds-office,                                ~
С типом скидки,dis-gds-rule,                      ~
Правило скидки = ,dis-gds-rule-num,               ~
Имеют Атрибут РЕСТОРАНА на объ.,fbr-gds-obj,      ~
Атрибут РЕСТОРАНА на объ.=,fbr-gds-obj-val,       ~
С атриб. на объекте,gds-obj-attr,                 ~
Атрибут на объ.= ,gds-obj-attr-val,               ~
С атриб. на фирме,gds-host-attr,                  ~
Атрибут на фирме= ,gds-host-attr-val,             ~
С глоб. атрибутом,goods-attr,                     ~
Глобальный атрибут= ,goods-attr-val,              ~
Налог= у всех тов.,tax-rate-value,                ~
Налог= у тов.объ.,tax-rate-value-obj,             ~
Проходившие,input,                                ~
С ценами>0,with-price,                            ~
Треб. переоценки,ov-req,                          ~
Треб. инвентар-и,inv-req,                         ~
Мобильн. сканер,scaner,                           ~
Цены эталона,etalon,                              ~
Товары на весах,scales-gds,                       ~
Товары на весах №,scales-gds-num,                 ~
Просроч.партии своб.зоны,parts-last-date,         ~
ФиБ партии своб.зоны,parts-fib,         ~
Товары с продажей по партиям, cashparts,          ~
Список док-тов,doc-list,                          ~
Список произ-лей,prod-list,                       ~
Список пост-ков,supp-list,                        ~
Список контр-тов,cli-list,                        ~
Ассорт.Матрицы,ass-matr,                          ~
Ассорт.Минимумы,ass-min,                          ~
ИЖТ на объ.,izt,                                  ~
ABC-анализы,abc-analysis,                         ~
XYZ-анализы,xyz-analysis,                         ~
ABC-XYZ-анализы,abcxyz,                           ~
Коллекции,collection,                             ~
Нет ингредиентов рецептов,no-recipe-gds,           ~
Неактивные,deleted,                                ~
Виды алкогольной продукции,choose-alc-prod,        ~
С движением за период с:,move-date"

&glob no-browser-option '':U

/* ***************************  Definitions  ************************** */

define new shared variable body-handle as handle no-undo.
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/get-regf.i }

define variable rs-list-method as character no-undo .
define variable lns-ignore as integer no-undo .
define variable notes as character no-undo .
define variable v-seq as integer no-undo .
define variable v-no-hist as integer no-undo init -1.
define variable lns-cnt as integer no-undo .
define variable line-mode as character no-undo .
define variable line-rec as recid no-undo .
define variable v-num-add          as integer no-undo .
define variable v-num-ignored      as integer no-undo .
define variable g#report-num as integer no-undo .
define variable v-no-obj as logical no-undo .
define variable v-rid-list as character no-undo .
define buffer buf_clients for ub.clients.
define variable v-user-select as logical no-undo .
define variable v-sel-obj-type like ub.clients.obj-type no-undo .
define variable v-sel-obj-code like ub.clients.obj-code no-undo .
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable macro-play-option as character no-undo .
define variable v-docs-all as logical no-undo .
define variable v-docs-cmp as logical no-undo .

{ cmp/gds-list.i {1} def shared }
{ str/listhprc.i {1}  }
{ str/libbcrcn.i }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ cmp/r-pril.i new }
{ gbl/userobjs.i }
{ gbl/key-rec.i }

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
define variable list-abcxyz          as character           no-undo .

define buffer l-{1} for {1}. /* для поиска  */

define stream sout.

{ gbl/flt-def.i }
{ arc/gds_inf.i def}
{ gbl/fltfield.i }
{ ref/gdsoattr.i "interface" parparentproc }
{ ref/gds-attr.i "interface" parparentproc }
{ ref/gdshattr.i "interface" parparentproc }
{ ref/grplibfn.i }
{ ref/cgrplbfn.i }

FUNCTION stat-line RETURNS CHARACTER
  (input p-status-chr as character )  FORWARD.


/* ***********************  Control Definitions  ********************** */

DEFINE MENU m-save
      MENU-ITEM m-gds-save      LABEL "Файл списка товаров"
&if "{1}" = "scn-list" &then
      MENU-ITEM m-scn-save      LABEL "Файл мобильного сканера"
&else
      MENU-ITEM m-scn-save      LABEL "Файл ТСД"
&endif
      MENU-ITEM m-xls-save      LABEL "Таблица EXCEL"
      MENU-ITEM m-title-save    LABEL "Имя Списка"
      MENU-ITEM m-macros-save   LABEL "Макрос формирования списка"
      MENU-ITEM m-gds-save-db   LABEL "Хранимый в БД список товаров"
      MENU-ITEM m-macros-save-db   LABEL "Хранимый в БД макрос формирования списка"
      RULE
      MENU-ITEM m-rum           LABEL "Операции над списком"
      .

DEFINE MENU m-play
      MENU-ITEM m-macro-file    LABEL "Сохраненный в файле макрос формирования списка товаров"
      MENU-ITEM m-macro-lob     LABEL "Сохраненный в БД макрос формирования списка товаров"
      .


DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B-obj"
     SIZE 3 BY 1.

DEFINE BUTTON b-save
    LABEL "&Эксп./Вып.":L
    SIZE 10 BY 1
    tooltip "Сохр. список тов. в текст. файле, файле сканера, EXCEL; операции над списком".

DEFINE BUTTON b-add
    LABEL "&+Доб. строку":L
    SIZE 15 BY 1
    tooltip "Добавить в список товаров 1 строку".

DEFINE BUTTON b-del
    LABEL "&-Удал. строку":L
    SIZE 15 BY 1
    tooltip "Удалить из списка товаров текущую строки".

DEFINE BUTTON b-rest
    LABEL "&*Остав. строку":L
    SIZE 15 BY 1
    tooltip "Оставить в списке только текущую строку".

DEFINE BUTTON b-ext
    LABEL "":L
    SIZE 12 BY 1
    tooltip "Запустить внешнюю процедуру".

DEFINE BUTTON b-exit AUTO-GO
    LABEL "&Выход ":L
    SIZE 10 BY 1
    tooltip "Выход из списка товаров (передача списка другой программе)".

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
    tooltip "Печать списка товаров".

DEFINE BUTTON b-lkp
    LABEL "&Просмотр":L
    SIZE 10 BY 1
    tooltip "Просмотр описания текущего товара".

DEFINE BUTTON b-clr
    LABEL "&Oчистить":L
    SIZE 10 BY 1
    tooltip "Удалить из списка все товары (строки)".

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


DEFINE BUTTON b-arch
    LABEL "А&рхив":L
    SIZE 10 BY 1
    tooltip "Расчет итоговой информации по всему списку товаров".

DEFINE BUTTON B-sel
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.


DEFINE VARIABLE dsp-rs AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
    SIZE 80 BY 1
    tooltip "Строка текущего состояния списка"
    FGCOLOR 4
    no-undo.

DEFINE VARIABLE f-tot-lns AS integer FORMAT ">>>>>>>>9":U
      VIEW-AS TEXT
    SIZE 10 BY 0.70
    tooltip "Кол. строк"
    FGCOLOR 4
    no-undo.


DEFINE VARIABLE RS-status AS character
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
    SIZE 34.75 BY 1 NO-UNDO.

DEF VAR loc-art AS CHAR VIEW-AS fill-in size 14 by 1
    tooltip "Начало артикула для поиска строки"
    fgcolor 12 no-undo.
DEF VAR loc-name AS CHAR VIEW-AS fill-in size 20 by 1
    tooltip "Начало названия товара для поиска строки"
    fgcolor 12 no-undo.
DEF VAR loc-code AS CHAR VIEW-AS fill-in size 20 by 1
    tooltip "Код (бар-код) для поиска строки"
    fgcolor 12 no-undo.

DEF VAR a-n-c AS CHAR VIEW-AS RADIO-SET horizontal /* vertical */ RADIO-BUTTONS
"&А","art",
"&Н","name",
"&К","code"
SIZE 12 BY 1
    tooltip "Выбор режима поиска: А - артикул, Н - начало названия, К - код (бар-код)"
    no-undo.

define variable v-obj-type as character view-as fill-in size  4 by 1 fgcolor 12 no-undo.
define variable v-obj-code as integer   view-as fill-in size  6 by 1 fgcolor 12 no-undo.
define variable v-obj-name as character view-as fill-in size 30 by 1 fgcolor 12 no-undo format "x(30)":U.


DEFINE QUERY BR-option FOR
      temp-list SCROLLING.

DEFINE BROWSE BR-option QUERY BR-option
DISPLAY
temp-list.fname format "X(255)"  width 60
WITH NO-LABELS SIZE 25 BY 22 ROW-HEIGHT-CHARS .57  separators
tooltip "Условие для выбора товаров, которые будут добавлены / удалены / оставлены в списке"
.

DEFINE QUERY br-list FOR {1} SCROLLING.

DEFINE BROWSE br-list QUERY br-list NO-LOCK DISPLAY
      {1}.to-sel  format "+/" column-label "*"
      {1}.gds-code FORMAT "99999999999":U
      {1}.artic
      {1}.gds-name &if "{1}" = "scn-list" &then format "x(25)"
      {1}.qnty column-label "Количество" format "->>>,>>9.999" &endif
      {1}.unit-base column-label "Изм" format "x(3)"
      (if {1}.stts = 0 then no else yes) column-label "-" format "-/ "
      {1}.grp-name
      ({1}.prod-type + " " + string ({1}.prod-code, ">>>>>>>>>9") ) column-label "Производитель" format "x(9)"
      &if "{1}" = "scn-list" &then
      enable {1}.qnty
      &endif
      WITH SIZE 74 BY 16 separators.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME {&frame-name}
    dsp-rs  AT ROW 1 COL 1 NO-LABEL
    b-help  AT ROW 1 COL 61
    br-option AT ROW 2 COL 75
    b-exit  AT ROW 2 COL 1
    b-save  AT ROW 2 COL 11
    b-print AT ROW 2 COL 21
    b-arch  AT ROW 2 COL 31
    b-hist  AT ROW 2 COL 41
    b-lkp   AT ROW 2 COL 51
    b-clr   AT ROW 2 COL 61
    b-mark  AT ROW 3 COL 1
    b-sel   AT ROW 3 COL 4
    a-n-c   at row 3 col 2 no-label
    b-add   AT ROW 3 COL 16
    b-del   AT ROW 3 COL 31
    b-rest  AT ROW 3 COL 46
    b-ext   AT ROW 3 COL 61
    v-obj-type at row 4 col 2 No-LABEL
    v-obj-code at row 4 col 6 No-LABEL
    b-obj at row 4 col 12
    v-obj-name at row 4 col 15 No-LABEL
    loc-art  AT ROW 4 COL 50 COLON-ALIGNED label "Начало артикула"
    loc-name AT ROW 4 COL 50 COLON-ALIGNED label "Начало названия" format "x(40)"
    loc-code AT ROW 4 COL 50 COLON-ALIGNED label "Бар-код (весь)" format "x(13)"
    b-macro AT ROW 4 col 68
    b-record AT ROW 4 col 71
    b-stop   AT ROW 4 col 71
    b-clear-macro AT ROW 4 col 71
    RS-status at row 5 col 2 no-label
    f-tot-lns AT ROW 5.25 col 65 no-label
    br-list  AT ROW 6 COL 1
    ub.clients.obj-name  at row 22 col 6 colon-aligned label "Пр-ль" fgcolor 4
    ub.gds-prt.node-name at row 22 col 40 colon-aligned label "Шкала" fgcolor 4
    ub.bar-code.b-code   at row 22 col 60 colon-aligned label "Код" format "9999999999" fgcolor 4
    SPACE(0) SKIP(0)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
        SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
        TITLE "СПИСОК  ТОВАРОВ":L
        DEFAULT-BUTTON b-exit.


&scop sel-obj ~
  ref-list = "":U. ~
  ~{ gbl/uobjsone.i       ~
    parparentproc         ~
    v-cntxt-db-num        ~
    v-cntxt-userid        ~
    v-cntxt-host-code-obj ~
    v-cntxt-obj-type      ~
    v-cntxt-obj-code      ~
    v-user-select         ~
    v-sel-obj-type        ~
    v-sel-obj-code        ~
  ~}                      ~
  if not v-user-select then do: ~
    run UI-on in this-procedure . ~
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
  b-macro:POPUP-MENU IN FRAME {&frame-name} = MENU m-play:HANDLE
  FRAME {&frame-name}:SCROLLABLE = FALSE
  b-save:MENU-MOUSE = 1
  b-macro:menu-mouse = 1
  .


/* ************************  Control Triggers  ************************ */

on
  return of
  &if "{1}" = "scn-list" &then
  {1}.qnty in browse br-list,
  &endif
  br-list in frame {&frame-name} do:

  /* убиваем return, чтоб не вылетала из списка */
  apply "choose" to b-lkp in frame {&frame-name}.
  return no-apply.
end.

on GO of frame {&frame-name} do:
define variable glog as logical no-undo .
  &if "{2}" = "managed" &then
  if lookup({&lob-res-list}, bttns) > 0 then do:
    message
    "Хотите добавить/изменить хранимый список товаров?"
    view-as alert-box question
    buttons yes-no update glog
    .
    if glog then do:
      run m-gds-save-db-proc in this-procedure no-error.
    end.
  end.
  if lookup({&lob-res-list-macro}, bttns) > 0 then do:
    message
    "Хотите добавить/изменить хранимый макрос формирования списка товаров?"
    view-as alert-box question
    buttons yes-no update glog
    .
    if glog then do:
      run m-macros-save-db-proc in this-procedure no-error .
    end.
  end.
  &endif
end.

on choose of b-obj in frame {&FRAME-NAME} do:
  run proc-b-obj in this-procedure ( input "change":U ).
end.

ON CHOOSE OF b-save DO:
  run gbl/pop-up.p ( input self :handle, input no ) no-error.
  if error-status :error then do: return no-apply. end.
end.


ON CHOOSE OF MENU-ITEM m-title-save /* ИМЯ СПИСКА  */ DO:
define variable v-value as character no-undo .
  run gbl/d-prompt.w (
      'title=':u + "Введите ИМЯ СПИСКА ТОВАРОВ" + '\':u
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
frame {&frame-name}:title = substitute("СПИСОК  ТОВАРОВ &1", v-value).
END.

ON CHOOSE OF MENU-ITEM m-gds-save /* Файл списка товаров */ DO:
define variable glog as logical no-undo .
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
  assign
    f-name = "default.gds"
    glog = yes
    .

  system-dialog get-file f-name
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
  output to value (f-name).
  for each {1}:
    export {1}.prod-type
          {1}.prod-code
          {1}.artic
          {1}.qnty
          .
  end.
  output close.
END.

ON CHOOSE OF MENU-ITEM m-gds-save-db /* Хранимый файл списка товаров */ DO:
define variable v-rid-list as character no-undo .
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
run m-gds-save-db-proc in this-procedure .
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

ON CHOOSE OF MENU-ITEM m-macros-save-db /* Хранимый файл макроса */ DO:
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
run m-macros-save-db-proc in this-procedure .
END.



ON CHOOSE OF MENU-ITEM m-xls-save /* EXCEL */ DO:
define variable glog as logical no-undo .
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
do on stop  undo, return no-apply
  on error undo, return no-apply
  on quit  undo, return no-apply
:
&if "{1}" = "scn-list":U &then
  run str/scnl-xls.p (parparentproc, p-curr-obj-type, p-curr-obj-code) no-error.
&else
  run str/gdsl-xls.p (parparentproc, p-curr-obj-type, p-curr-obj-code) no-error.
&endif
  run waitfram-hide in this-procedure .
end.
END.

ON CHOOSE OF MENU-ITEM m-rum /* Операции над списком */ DO:
define variable glog as logical no-undo .
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input "utl/thbjrumr.w":U
    , input {&table_goods} + {&delim-par} +
            ({&goods-proc_batchwork-export} + {&comma-char} + {&goods-proc_batchwork-routing})
              /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input "&Стоп"
    , input substitute("Операции на списком товаров") ) .

END.


&global-define store-type p-curr-obj-type
&global-define store-code p-curr-obj-code
&global-define parparentproc parparentproc
{ str/sch-line.i {1} br-list }
{&disp-hot-fields}
end.

ON CHOOSE OF b-print IN FRAME {&frame-name} DO:
&if "{1}" = "scn-list" &then
run rep/pri-lst.w (
               input parparentproc
             , input p-curr-obj-type
             , input p-curr-obj-code
             , input "LIST"
             , input "gds-list"
             ).
&else
run rep/pri-lst.w (
                input parparentproc
              , input p-curr-obj-type
              , input p-curr-obj-code
              , input "ALL"
              , input "gds-list"
              ).
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
run str/showgds.p (input parparentproc
                  ,input this-procedure:handle  /*p-call-handle*/
                  ,input ub.goods.gds-code
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
SPACE(25) "История создания списка товаров "
(if available buf_{1}-hist
then buf_{1}-hist.des
else "БЕЗЫМЯННЫЙ") skip(0)
space(25) cur-time-print() skip(1)
.
put stream PrnLibStream unformatted
string("№", "X(9)") {&space-char}
string("Действие", "X(9)") {&space-char}
string("записей", "X(9)") {&space-char}
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
  string(buf_{1}-hist.num-add, ">>>>>>>>9") {&space-char} {&space-char} {&space-char} {&space-char}
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

ON CHOOSE OF b-ext IN FRAME {&frame-name} DO:
    define buffer buf_goods     for ub.goods.
    define buffer buf_{1}       for {1}.

    define variable v-goods-recid     as recid         no-undo.

    for each temp_recid-list
    :
        delete temp_recid-list.
    end.

    if available {1}
    then do:
        find first buf_goods no-lock
            where buf_goods.gds-code     = {1}.gds-code
        .
        v-goods-recid = recid( buf_goods ).
        for each buf_{1}
        :
            find first buf_goods no-lock
                where buf_goods.gds-code = buf_{1}.gds-code
            .
            create temp_recid-list .
            assign
                temp_recid-list.string-goods-recid = string( recid( buf_goods ) )
            .
        end.
    end.
    else do:
        assign
            v-goods-recid = 0
        .
    end.
    run str/run-ext.p ( input v-goods-recid
                  , input table temp_recid-list
                  , input {&goods}
                  , input ""
                  , output v-ext-button-label
                  ) no-error.
    if error-status :error
    then do:        /* Ошибка при выполнении внешней программы или нет прав */
        return no-apply .
    end.
END.

ON CHOOSE OF b-arch IN FRAME {&frame-name} DO:
run list_inf-local in this-procedure .
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
                                     , input "# Список товаров очищен."
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
run UI-on in this-procedure .
END.

ON VALUE-CHANGED OF RS-Status IN FRAME {&frame-name} DO:
  assign
  RS-status.
END.


&if "{1}" = "scn-list" &then
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


{ gbl/app_help.i &disable_diasize=true }
{ gbl/diasize.i &browse-name="br-list" }

{ str/an-listp.i {1} gds-list gdm {2} }
if lookup(bttns, "hide") = 0 then do:
  run diasize_add_browse in this-procedure
    (input  'height':u
    ,input  browse BR-option :handle
    ) .
  run diasize_init in this-procedure .
end.



define variable v-ok as logical   no-undo .
assign
  v-ok = br-list :set-repositioned-row(5, 'conditional':u)
.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

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
  if g#auto then do:
    v-no-context = yes.
  end.
  else do:
    { gbl/getcntxt.i get }
  end.

  run get-report-num in parparentproc ( output g#report-num ).
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
   if v-user-select then do:
      find first buf_clients no-lock where
                buf_clients.obj-type = v-sel-obj-type
            and buf_clients.obj-code = v-sel-obj-code no-error.
      if not available buf_clients then return error.
      assign
      p-curr-obj-type = buf_clients.obj-type
      p-curr-obj-code = buf_clients.obj-code
      p-curr-host-code = buf_clients.host-code
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
      or buf_clients.host-code <> p-curr-host-code
      )
    then do:
      assign
      p-curr-obj-type = '':U
      p-curr-obj-code = 0
      p-curr-host-code = 0
      .
      message
      vss-workfile vss-revision vss-description skip
      "Неверно заданы входные параметры p-curr-host-code и/или p-curr-obj-type и/или p-curr-obj-code"
      p-curr-host-code p-curr-obj-type p-curr-obj-code
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
 { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_documents_all':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  false
  v-docs-all
  }
 { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_documents_company':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  false
  v-docs-cmp
  }
  assign
  br-option:column-scrolling in frame {&frame-name}  = no
  {1}.gds-name:resizable in browse br-list = true
  {1}.grp-name:resizable in browse br-list = true
  RS-status:radio-buttons = "Текущие&+" + {&comma-char} + {&current} + {&comma-char} +
                            "Все!" + {&comma-char} + {&all} + {&comma-char} +
                            "Неактивные-" + {&comma-char} + {&deleted}
  RS-status = {&current}
  .
    /*заполним temp-list*/
    run proc-fill-temp-list in this-procedure .
    &if "{1}" = "gds-list" &then
    /*---START--------- Включить/выключить кнопку запуска внешней программы ---------------------*/
        run str/run-ext.p ( input ?
                      , input table temp_recid-list
                      , input {&goods}
                      , input "init"
                      , output v-ext-button-label
                      ) no-error.
        if error-status :error
        then do:        /* Не выводим кнопку: ошибка при инициализации или нет прав */
            assign
                b-ext :visible   = no
            .
        end.
        else do:
            assign
                b-ext :label     = v-ext-button-label
                b-ext :visible   = yes
                b-ext :sensitive = yes
            .
        end.
    /*---END----------- Включить/выключить кнопку запуска внешней программы ---------------------*/
    &endif

  if v-no-obj
  or v-cntxt-level <> {&cntxt-object} then do:
    if v-obj-name = "":U then do:
      run proc-b-obj in this-procedure ( input "":U ).
    end.
    if lookup(bttns, "hide") = 0 then do:
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
  end.
&if "{2}" = "pre-macro" &then
  run request-create-macro-list-hist  in p-parent-handle ( input this-procedure:handle).
  run proc-macro-play in this-procedure ( input 0, input yes, input 0).
&endif
  if lookup(bttns, "hide") > 0 then do:
    return.
  end.
  run UI-on in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-list.
END.
HIDE FRAME {&frame-name}.

/* **********************  Internal Procedures  *********************** */

PROCEDURE UI-on:
define variable v-recid0 as recid no-undo.
define variable v-start as logical no-undo .
define buffer buf_temp-list for temp-list.
define buffer buf_{1}-hist for {1}-hist.
  find first buf_{1}-hist where buf_{1}-hist.id = 0 no-error.
  if available buf_{1}-hist then
  assign
  frame {&frame-name}:title = substitute("СПИСОК  ТОВАРОВ &1",  string(buf_{1}-hist.des, "X(60)"))
  .
  &if "{2}" = "pre-macro" or "{2}" = "managed" &then
    assign
    frame {&frame-name}:title = p-title
    .
  &endif
  if tot-lns = ? then do:
    /* первоначальное заполнение истории списка при входе в него */
    v-start = yes.
    for each l-{1} :
      accumulate l-{1}.artic (count).
    end.
    tot-lns = (accum count l-{1}.artic).
    if tot-lns > 0 then do:
      find last  buf_{1}-hist no-error .
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
                                           , input "# Исходный список товаров пуст."
                                           , input tot-lns
                                           , input 'start':U
                                           , input '':U
                                           , input '':U
                                           , input '':U
                                           , input ?
                                           ).
    end.
  end.
  hide loc-art in frame {&frame-name} loc-name loc-code in frame {&frame-name}.
  assign
  loc-art = ""
  RS-list-method = "single"
  .
  find first buf_temp-list no-lock where
             buf_temp-list.fvalue = rs-list-method.
  assign
  v-recid0 = recid(buf_temp-list).
  {&OPEN-BR-option}
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
  &if "{2}" = "pre-macro" &then
  assign
  b-add:label = "Исходн.сп."
  .
  &endif
  if v-start then do:
    hide
    b-sel
    b-mark
    b-stop
    b-clear-macro
    in frame {&frame-name}.
    if lookup("b-sel", bttns) > 0
    or lookup("b-mark", bttns) > 0
    then do:
      {1}.to-sel:visible in browse br-list = yes.
    end.
    else do:
      {1}.to-sel:visible in browse br-list = no.
    end.
    if bttns <> '':U then do:
      run proc-expand in this-procedure ( input 1, input b-sel:row, input br-list:row, input "b-sel,b-mark").
    end.
  end.
  v-start = no.
  &if "{1}" <> "scn-list" &then
  if is-tsd = no then do:
    menu-item m-scn-save:sensitive in menu m-save = no.
  end.
  &if "{2}" = "managed" &then
  if lookup({&lob-res-list}, bttns) > 0 then do:
     menu-item m-gds-save-db:sensitive  in menu m-save = no.
  end.
  if lookup({&lob-res-list-macro}, bttns) > 0 then do:
     menu-item m-macros-save-db:sensitive  in menu m-save = no.
  end.
  &endif
  &endif
  reposition br-option to recid v-recid0.
 
  if tot-lns > 0 then do:
   /* View b-print. Enable b-print. b-print:move-to-top(). */
    Enable b-print b-arch b-rest b-save b-del b-lkp b-clr a-n-c
    b-mark when lookup("b-mark", bttns) > 0
    b-sel  when lookup("b-sel", bttns) > 0
    WITH FRAME {&frame-name}.
  end.  
  else do:
    DISABLE b-print b-arch b-rest b-save b-del b-lkp b-clr a-n-c
    b-mark b-sel
    WITH FRAME {&frame-name}.
  end.
  {&open-br}
  if line-rec <> ? then
    reposition br-list to recid line-rec no-error.
  /* Отключено, т.к. после reposition в updatable browse последняя строка выводится повторно на месте 1-й.
    Включается только в старом варианте списка */
  &if "{1}" <> "scn-list" &then
  apply "entry" to br-list in frame {&frame-name}.
  &endif
  /* Отключено, т.к. после reposition в updatable browse последняя строка выводится повторно на месте 1-й.
    Вместо этого скопирован следующий кусок кода из триггера на iteration-changed.
    apply "iteration-changed" to br-list in frame {&frame-name}. */
  {&disp-hot-fields}
END PROCEDURE.

{ cmp/ex-gds.i {1} {&frame-name} }

PROCEDURE rs-do:
define input parameter p-from-macro as logical no-undo .
define input parameter p-step as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .
/* обработка нажатия батона в зависимости от rs */
define variable grp-path like ub.goods.grp-name no-undo.
define variable another-price like ub.price-list.price-sale no-undo.
define variable var-root-code like ub.gds-prt.node-code no-undo .
define variable v-rowid   as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-discnt-role as character no-undo .
define variable v-nonunique as character no-undo .
define variable vvalue-int as integer no-undo .
define variable glog as logical no-undo .
define variable v-date-chr as character no-undo .
define variable v-date as date no-undo .
define buffer buf_{1}-hist for {1}-hist.
define buffer buf_user-obj for ub.user-obj.
define buffer buf_units for ub.units.
define buffer buf_parts for ub.parts.

do
on error undo, return error return-value
:

assign
lns-cnt = 0
lns-ignore = 0
v-num-add     = 0
v-num-ignored = 0
tot-lns = (if line-mode = {&leave} then 0 else tot-lns)
.

run write-hist in this-procedure ( input p-from-macro
                                  ,input rs-list-method
                                  ,input rs-status
                                  ,input line-mode).

if session:set-wait-state( "COMPILER" )  then .
dsp-rs:fgcolor in frame {&frame-name} = 12.
case rs-list-method:
  when "all" then do:
    find first buf_{1}-hist where
               buf_{1}-hist.id = p-id .
    for each ub.goods no-lock:
      run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "gds-grp" then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid}  next.
      grp-path = "".
      find first ub.gds-grp no-lock where rowid(ub.gds-grp) = v-rowid.
      run grplib-get-full-name in this-procedure (ub.gds-grp.node-code, output grp-path).
      for each ub.goods where ub.goods.grp-name begins grp-path no-lock:
        run ex-gds  in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end.
  end.
  when "goods" or
  when "gds-obj":U  or
  when "gds-obj-fact":U  or
  when "gds-obj-free":U  or 
  when "tsd" then do:

    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid} next.
      find ub.goods where rowid (goods) = v-rowid no-lock.
      run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      {&assign-nums}.
    end.
  end.
  when "grp-prod"
  or
  when "grp-supp"
  then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next.
      find ub.cli-grp where rowid (ub.cli-grp) = v-rowid no-lock.
      grp-path = "".
      run cli-grplib-get-full-name in this-procedure (ub.cli-grp.node-code, output grp-path).
      for each ub.clients where ub.clients.grp-name begins grp-path no-lock:
        if rs-list-method = "grp-prod" then do:
        for each ub.goods where ub.goods.prod-type = ub.clients.obj-type
                        and ub.goods.prod-code = ub.clients.obj-code no-lock:
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
        end.
        if rs-list-method = "grp-supp" then do:
          for each ub.cli-gds where ub.cli-gds.cli-type = ub.clients.obj-type
                            and ub.cli-gds.cli-code = ub.clients.obj-code
                            and ub.cli-gds.host-code = p-curr-host-code no-lock,
              each ub.goods where goods.artic = ub.cli-gds.artic
                            and ub.goods.prod-type = ub.cli-gds.prod-type
                            and ub.goods.prod-code = ub.cli-gds.prod-code no-lock:
            run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      end.
      {&assign-nums}.
    end.
  end.
  when "producer"
  or
  when "supplier"
  then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next.
      find clients where rowid (clients) = v-rowid no-lock.
      if rs-list-method = "producer" then do:
        for each ub.goods where ub.goods.prod-type = ub.clients.obj-type
                        and ub.goods.prod-code = ub.clients.obj-code no-lock:
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      if rs-list-method = "supplier" then do:
        for each ub.cli-gds where ub.cli-gds.cli-type = ub.clients.obj-type
                          and ub.cli-gds.cli-code = ub.clients.obj-code
                          and ub.cli-gds.host-code = p-curr-host-code
                          and ub.cli-gds.in-qnty <> 0 no-lock,
            first ub.goods where ub.goods.artic = ub.cli-gds.artic
                        and ub.goods.prod-type = ub.cli-gds.prod-type
                        and ub.goods.prod-code = ub.cli-gds.prod-code no-lock:
          run ex-gds  in this-procedure( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      {&assign-nums}.
    end.
  end.
  when "choose-alc-prod"
  then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next.
      find alc-type where rowid (alc-type) = v-rowid no-lock.
      if rs-list-method = "choose-alc-prod" then do:
        for each alc-type-gds where alc-type-gds.alc-type-inner-code = alc-type.alc-type-inner-code no-lock,
            first goods where goods.gds-code = alc-type-gds.gds-code no-lock:
          run ex-gds  in this-procedure( buffer goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      {&assign-nums}.
    end.
  end.

  when "object" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U.
    {&get-rowid} do: end. else do:
     run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj where ub.gds-obj.obj-type = v-user-obj-type
                        and ub.gds-obj.obj-code = v-user-obj-code no-lock,
          first ub.goods where ub.goods.prod-type = ub.gds-obj.prod-type
                      and ub.goods.prod-code = ub.gds-obj.prod-code
                      and ub.goods.artic = ub.gds-obj.artic no-lock:
        run ex-gds in this-procedure( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end.
  end.
  when "etalon" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U.
    {&get-rowid} do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj where
            ub.gds-obj.obj-type = p-curr-obj-type and
            ub.gds-obj.obj-code = p-curr-obj-code no-lock,
        first ub.goods where
            ub.goods.prod-type = ub.gds-obj.prod-type and
            ub.goods.prod-code = ub.gds-obj.prod-code and
            ub.goods.artic     = ub.gds-obj.artic no-lock,
        each ub.gds-prt where
            ub.gds-prt.upper-code = ub.goods.prt-root no-lock,
        each ub.bar-code where
            ub.bar-code.gds-code  = ub.goods.gds-code and
            ub.bar-code.node-code = ub.gds-prt.node-code and
            ub.bar-code.unit-cli  = ub.goods.unit-base and
            ub.bar-code.in-code   = "" and
            ub.bar-code.part-code = "" no-lock:
        find last ub.price-list where
                  ub.price-list.obj-type  = p-curr-obj-type and
                  ub.price-list.obj-code  = p-curr-obj-code and
                  ub.price-list.b-code    = ub.bar-code.b-code and
                  ub.price-list.price-type = ""
                  use-index fact-close no-lock no-error.
        if available ub.price-list and
          ub.price-list.fact-order <> 0 then do:
          another-price = ub.price-list.price-sale.
          find last ub.price-list where ub.price-list.obj-type  = v-user-obj-type
                                and ub.price-list.obj-code  = v-user-obj-code
                                and ub.price-list.b-code    = bar-code.b-code
                                use-index fact-close no-lock no-error.
          if available ub.price-list and
            ub.price-list.fact-order <> 0 and
            ub.price-list.price-sale <> another-price then
            run ex-gds  in this-procedure( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end. /*for each */
    end.
    {&assign-nums}.
  end. /*"etalon"*/
  when "waybill" then do:
    glog = no.
    _ii:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next _ii.

      find first ub.trn-doc no-lock where
              rowid(ub.trn-doc) = v-rowid no-error.
      if not avail ub.trn-doc then next _ii.
      &if "{1}" = "scn-list" &then
      if p-from-macro and not p-step then do:
        glog = yes.
      end.
      else do:
        if can-do ({&expense_income_return_write-off}, trn-doc.doc-type) then
          message "При добавлении товаров, которые уже есть в списке, прибавить к ним факт количества из накладной ?" skip
                  "Приход и возврат прибавляются, расход и списание вычитаются." skip (2)
                  "Внимание! Общее количество не может быть меньше 0 (будет выдано сообщение и заменено на 0)!"
                  view-as alert-box question buttons OK-Cancel update glog.
      end.
      &endif
      for each ub.doc-line where ub.doc-line.doc-code = ub.trn-doc.doc-code no-lock,
          first ub.goods where ub.goods.artic     = ub.doc-line.artic
                        and ub.goods.prod-type = ub.doc-line.prod-type
                        and ub.goods.prod-code = ub.doc-line.prod-code no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        if glog and
            /* количество пишем, если есть запись (не удаление и не попытка добавить удаленный товар),
                если это не запись, оставшаяся от предыдущего цикла */
            available {1} and
            {1}.artic = ub.goods.artic and
            {1}.prod-type = ub.goods.prod-type and
            {1}.prod-code = ub.goods.prod-code then do:
          {1}.qnty = if can-do ({&expense_write-off}, ub.trn-doc.doc-type) then
                      {1}.qnty - ub.doc-line.fact-qnty
                    else
                      {1}.qnty + ub.doc-line.fact-qnty.
          /* отрицательное количество заменяем на 0, поскольку не можем его показать в списке (не даем руками его ввести),
            не можем его выкачать и не можем вкачать в инвентаризацию */
          if {1}.qnty < 0 then do:
            if not p-from-macro or p-step then
            message "Артикул:" ub.doc-line.artic skip
                    "Количество в накладной:" ub.doc-line.fact-qnty skip
                    "Итоговое количество в списке:" {1}.qnty skip (2)
                    "Заменено на 0."
                    view-as alert-box .
            {1}.qnty = 0.
          end. /* if {1}.qnty < 0 t*/
        end. /* if glog and */
      end. /* for each doc-line */
      {&assign-nums}.
    end. /* for each buf_{1}-hist */
  end. /* when waybill */
  when "manufacture" then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next.
      find first ub.fbr-doc no-lock where
                rowid(ub.fbr-doc) = v-rowid.
      for each ub.fbr-line where ub.fbr-line.doc-code = ub.fbr-doc.doc-code no-lock,
          first ub.goods where ub.goods.artic = ub.fbr-line.artic
                      and ub.goods.prod-type = ub.fbr-line.prod-type
                      and ub.goods.prod-code = ub.fbr-line.prod-code no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end.
  end.
  when "recipe" then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next.
      find first ub.recipe no-lock where rowid(recipe) = v-rowid.
      for each ub.recipe-gds where ub.recipe-gds.recipe-code = recipe.recipe-code no-lock,
          first ub.goods where ub.goods.artic = ub.recipe-gds.artic
                      and ub.goods.prod-type = ub.recipe-gds.prod-type
                      and ub.goods.prod-code = ub.recipe-gds.prod-code no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end.
  end.
  when "self-recipe" then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next.
      find first ub.recipe no-lock where rowid(ub.recipe) = v-rowid.
      find first ub.goods where goods.artic = ub.recipe.artic
                  and ub.goods.prod-type = ub.recipe.prod-type
                  and ub.goods.prod-code = ub.recipe.prod-code no-lock no-error.
      if available ub.goods then do:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end.
  end.

  when "contract" then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next.
      find first ub.contract no-lock  where rowid(ub.contract) = v-rowid.
/*
      for each ub.contract-specif where ub.contract-specif.contract-num = ub.contract.contract-code and
                                    ub.contract-specif.host-code    = ub.contract.host-code  no-lock,
*/
      {str/cont-slave-inc.i
           &FOR_ = YES
           &EACH_ = YES
           &BUFFER_SPECIF = ub.contract-specif
           &P_HOST_CODE = ub.contract.host-code
           &P_CONTRACT_NUM = ub.contract.contract-code
           &NO_LOCK=YES
           &NO_END=YES
      }
          ,
           first ub.goods where ub.goods.gds-code = contract-specif.gds-code no-lock :
        run ex-gds in this-procedure( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end. /*each buf_1-hist*/
  end. /*contract*/
  when "client" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_  <> '':U .
    {&get-rowid} do: end. else do:
      find first ub.clients no-lock where rowid(ub.clients) = v-rowid.
      for each ub.trn-doc where ub.trn-doc.cli-type = ub.clients.obj-type
                        and ub.trn-doc.cli-code = ub.clients.obj-code no-lock:
        for each ub.doc-line where doc-line.doc-code = trn-doc.doc-code no-lock,
            first ub.goods where ub.goods.artic = ub.doc-line.artic
                          and ub.goods.prod-type = ub.doc-line.prod-type
                          and ub.goods.prod-code = ub.doc-line.prod-code no-lock:
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      {&assign-nums}.
    end.
  end.
  when "consignee" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_  <> '':U .
    {&get-rowid} do: end. else do:
      find first ub.clients no-lock where rowid(clients) = v-rowid.
      for each ub.cli-gds where ub.cli-gds.cli-type = ub.clients.obj-type
                        and ub.cli-gds.cli-code = ub.clients.obj-code
                        and ub.cli-gds.out-qnty > ub.cli-gds.ret-qnty no-lock,
          first ub.goods where ub.goods.artic = ub.cli-gds.artic
                      and ub.goods.prod-type = ub.cli-gds.prod-type
                      and ub.goods.prod-code = ub.cli-gds.prod-code no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end.
  end.
  when "overvalue" then do:
    glog = no.
    _jj:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next _jj.
      find first ub.price-doc no-lock where
                rowid(ub.price-doc) = v-rowid no-error.
      if not avail ub.price-doc then next _jj.
      for each ub.price-list where ub.price-list.doc-num = ub.price-doc.doc-num no-lock,
          first ub.goods where ub.goods.prod-type = ub.price-list.prod-type
                        and ub.goods.prod-code = ub.price-list.prod-code
                        and ub.goods.artic = ub.price-list.artic no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end. /* for each buf_1-hist */
  end.
  when "pdf" then do:
    glog = no.
    _jj:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next _jj.
      find first ub.price-doc-forming no-lock where
                rowid(ub.price-doc-forming) = v-rowid no-error.
      if not avail ub.price-doc-forming then next _jj.
      for each ub.price-doc-forming-gds where
              ub.price-doc-forming-gds.plt-db-num = ub.price-doc-forming.plt-db-num
          and ub.price-doc-forming-gds.plt-id = ub.price-doc-forming.plt-id
          and ub.price-doc-forming-gds.pdf-db = ub.price-doc-forming.pdf-db
          and ub.price-doc-forming-gds.pdf-id = ub.price-doc-forming.pdf-id
      no-lock,
          first ub.goods where ub.goods.prod-type = ub.price-doc-forming-gds.prod-type
                        and ub.goods.prod-code = ub.price-doc-forming-gds.prod-code
                        and ub.goods.artic = ub.price-doc-forming-gds.artic no-lock:
        run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end. /* for each buf_1-hist */
  end.
    when "collection" then do:
        run str/any-li01.p (
                         input parparentproc
                        ,input this-procedure:handle
                        ,input "collection"
                        ,input p-from-macro
                        ,input rs-list-method
                        ,input rs-status
                        ,input line-mode
                        ,input p-id
                        ,INPUT-OUTPUT table buf_{1}-hist
                        ) no-error .
  end.

  when "abcxyz"
  or
  when "abc-analysis"
  or
  when "xyz-analysis" then do:
    run str/any-li01.p ( input parparentproc
                    ,input this-procedure:handle
                    ,input "analysis-do"
                    ,input p-from-macro
                    ,input rs-list-method
                    ,input rs-status
                    ,input line-mode
                    ,input p-id
                    ,INPUT-OUTPUT table buf_{1}-hist
                    ) no-error .
  end.
  when "ass-matr"
  or
  when "ass-min" then do:
    run str/any-li01.p ( input parparentproc
                    ,input this-procedure:handle
                    ,input rs-list-method /*rs-list-method  не всегда здесь так надо!!!!!*/
                    ,input p-from-macro
                    ,input rs-list-method
                    ,input rs-status
                    ,input line-mode
                    ,input p-id
                    ,INPUT-OUTPUT table buf_{1}-hist
                    ) no-error .
  end.
  when "izt" then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      assign
      v-attr-code  = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-obj-type = entry(2, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(3, buf_{1}-hist.item_, {&delim-key}))
      .
      for each ub.gds-obj-prop no-lock where
             ub.gds-obj-prop.obj-type  = v-obj-type
         and ub.gds-obj-prop.obj-code  = v-obj-code
         and lookup (ub.gds-obj-prop.gdop-igt , v-attr-code ) > 0 ,
          first ub.goods no-lock where
               ub.goods.gds-code = ub.gds-obj-prop.gds-code:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      if v-attr-code = {&ass-izd-empty} then do:
        for each ub.gds-obj no-lock where
                ub.gds-obj.obj-type  = v-obj-type
            and ub.gds-obj.obj-code  = v-obj-code:
          if not can-find ( first ub.gds-obj-prop where
                                 ub.gds-obj-prop.obj-type  = v-obj-type
                             and ub.gds-obj-prop.obj-code  = v-obj-code
                             and ub.gds-obj-prop.gds-code = ub.gds-obj.gds-code ) then   do:
            find first ub.goods no-lock  where
                      ub.goods.gds-code = ub.gds-obj.gds-code no-error .
            if available goods then
            run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
          end. /*if not can-find ( first gds-obj-prop where*/
        end. /*for each gds-obj no-lock where*/
      end. /*if v-attr-code = {&ass-izd-empty} then do:*/
    end. /* do num-rec = 1 to */
  end. /*when*/
  when "input" or when "with-price" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_  <> '':U .
    {&get-rowid} do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj where
              ub.gds-obj.obj-type = v-user-obj-type
          and ub.gds-obj.obj-code = v-user-obj-code no-lock,
          first ub.goods where
                ub.goods.gds-code = ub.gds-obj.gds-code:
        if rs-list-method = "with-price" then do:
          if ub.gds-obj.price-sale > 0
          AND ub.gds-obj.last-doc <> ? then do:
            run ex-gds  in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
          end.
        end. /*if rs-list-method = "with-price" then do:*/
        if rs-list-method = "input" then do:
          find first ub.parts no-lock where
                    ub.parts.obj-type  = ub.gds-obj.obj-type
                AND ub.parts.obj-code  = ub.gds-obj.obj-code
                AND ub.parts.artic = ub.gds-obj.artic
                AND ub.parts.prod-type = ub.gds-obj.prod-type
                AND ub.parts.prod-code = ub.gds-obj.prod-code no-error.
          if available ub.parts then do:
            run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
          end. /*if available parts then do:*/
        end. /*  if rs-list-method = "input" then do:*/
      end. /*for each gds-obj where*/
      {&assign-nums}.
    end. /*  {&get-rowid} do: end. else do:*/
  end. /*when*/
  when "available" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_  <> '':U .
    {&get-rowid} do: end. else do:
      &if "{1}" = "scn-list" &then
      if not p-from-macro or p-step then
      message "При чтении количеств из товаров, имеющихся в наличии они в списке будут переписаны.".
      &endif
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj where
              ub.gds-obj.obj-type = v-user-obj-type
          and ub.gds-obj.obj-code = v-user-obj-code
          and ub.gds-obj.fact-qnty > 0 no-lock,
          first ub.goods where
              ub.goods.gds-code = ub.gds-obj.gds-code no-lock:
        run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
        &if "{1}" = "scn-list" &then
          if available {1} then do:
            {1}.qnty = gds-obj.free-qnty.
          end.
        &endif
      end.
      {&assign-nums}.
    end.
  end.
  when "neg-part" or
  when "neg-part-free" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_  <> '':U .
    {&get-rowid} do: end. else do:
      /* это самый быстрый способ получить отрицательные партии */
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.parts where ub.parts.obj-type = v-user-obj-type
                      and ub.parts.obj-code = v-user-obj-code
                      and ub.parts.out-code = {&free-code}
                      and ub.parts.fact-qnty < 0 no-lock,
          first ub.goods where ub.goods.prod-type = ub.parts.prod-type
                        and ub.goods.prod-code = ub.parts.prod-code
                        and ub.goods.artic = ub.parts.artic no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      if rs-list-method <> "neg-part-free" then do: 
        for each ub.parts where ub.parts.obj-type = v-user-obj-type
                      and ub.parts.obj-code = v-user-obj-code
                      and ub.parts.out-code = {&output-code}
                      and ub.parts.fact-qnty < 0 no-lock,
          first ub.goods where ub.goods.prod-type = ub.parts.prod-type
                        and ub.goods.prod-code = ub.parts.prod-code
                        and ub.goods.artic = ub.parts.artic no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
      {&assign-nums}.
    end.
  end.
  when "neg-rest" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_  <> '':U .
    {&get-rowid} do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj where ub.gds-obj.obj-type = v-user-obj-type
                        and ub.gds-obj.obj-code = v-user-obj-code
                        and ub.gds-obj.fact-qnty < 0 no-lock,
          first ub.goods where ub.goods.prod-type = ub.gds-obj.prod-type
                      and ub.goods.prod-code = ub.gds-obj.prod-code
                      and ub.goods.artic = ub.gds-obj.artic no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end.
  end.
  when "neg-prt" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_  <> '':U .
    {&get-rowid} do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      { gbl/emptyscl.i var-root-code no-error }
      find first ub.gds-prt no-lock where
                ub.gds-prt.node-code = var-root-code no-error .
        _neg-prt-obj:
      for each ub.prt-obj no-lock where
              ub.prt-obj.obj-type = v-user-obj-type
          and ub.prt-obj.obj-code = v-user-obj-code,
          first ub.goods no-lock where
                ub.goods.prod-type = ub.prt-obj.prod-type
            and ub.goods.prod-code = ub.prt-obj.prod-code
            and ub.goods.artic = ub.prt-obj.artic:
        if ub.goods.prt-root = ub.gds-prt.upper-code then NEXT _neg-prt-obj.
        if NOT (ub.prt-obj.fact-qnty < 0) then next _neg-prt-obj.
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end.
  end.
  when "is-ptrl" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id  no-error .
    if error-status:error then do: end. else do:
      for each buf_units no-lock where
              lookup( {&petrolium}, buf_units.type) > 0,
          each ub.goods no-lock where
                ub.goods.unit-base = buf_units.unit-name:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end. /*for each buf_units*/
      {&assign-nums}.
    end.
  end. /*is-ptrl*/
  when "gds-office" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id  no-error .
    if error-status:error then do: end. else do:
      for each ub.goods no-lock:
        if ub.goods.gds-type = {&gds-office} then do:
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end. /*for each buf_units*/
      {&assign-nums}.
    end.
  end. /*gds-office*/
  when "nul-rest" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_  <> '':U .
    {&get-rowid} do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj where ub.gds-obj.obj-type = v-user-obj-type
                        and ub.gds-obj.obj-code = v-user-obj-code
                        and ub.gds-obj.fact-qnty = 0 no-lock,
          first ub.goods where ub.goods.prod-type = ub.gds-obj.prod-type
                        and ub.goods.prod-code = ub.gds-obj.prod-code
                        and ub.goods.artic         = ub.gds-obj.artic no-lock:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end.
  end.
  when "fbr-gds-obj-val"
  or when "fbr-gds-obj"
  then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U .
    assign
    v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
    v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
    v-attr-code  = (if rs-list-method = "fbr-gds-obj-val"
                    then entry(3, buf_{1}-hist.item_, {&delim-key})
                    else '':U)
    vvalue = (if rs-list-method = "fbr-gds-obj-val"
              then entry(4, buf_{1}-hist.item_, {&delim-key})
              else '':U)
    no-error
    .
    if error-status:error then do: end. else do:
      for each ub.fbr-gds-obj no-lock where
              ub.fbr-gds-obj.obj-type = v-obj-type
          and ub.fbr-gds-obj.obj-code = v-obj-code,
          first ub.goods no-lock where
                ub.goods.gds-code = ub.fbr-gds-obj.gds-code:
        if rs-list-method = "fbr-gds-obj-val" then do:
          CASE v-attr-code:
            when "is-cd":U then do:
              if string(ub.fbr-gds-obj.is-cd, "yes/no":U)  <> vvalue then NEXT.
            end.
            when "is-menu":U then do:
              if string(ub.fbr-gds-obj.is-menu, "yes/no":U)  <> vvalue then NEXT.
            end.
            when "is-null-price":U then do:
              if string(ub.fbr-gds-obj.is-null-price, "yes/no":U)  <> vvalue then NEXT.
            end.
            when "is-modificator":U  then do:
              if string(ub.fbr-gds-obj.is-modificator, "yes/no":U)  <> vvalue then NEXT.
            end.
            when "is-season":U then do:
              if string(ub.fbr-gds-obj.is-season, "yes/no":U)  <> vvalue then NEXT.
            end.
            when "is-semi-finished":U then do:
              if string(ub.fbr-gds-obj.is-semi-finished, "yes/no":U)  <> vvalue then NEXT.
            end.
            when "fbr-grp-code":u then do:
              if string(ub.fbr-gds-obj.fbr-grp-code)  <> vvalue then NEXT.
            end.
            when "fbr-obj-code":u then do:
              if string(ub.fbr-gds-obj.fbr-obj-code)  <> vvalue then NEXT.
            end.
          END CASE.
        end. /*if rs-list-method = */
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end. /*for each fbr-gds-obj*/
      {&assign-nums}.
    end.
  end. /*when "fbr-gds-obj" ...*/
  when "dis-gds-rule" or when "dis-gds-rule-num"  then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U no-error .
    assign
    v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
    v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
    v-discnt-role = entry(3, buf_{1}-hist.item_, {&delim-key})
    vvalue-int = (if rs-list-method = "dis-gds-rule" then 0 else integer(entry(4, buf_{1}-hist.item_, {&delim-key})))
    no-error
    .
    if error-status:error then do: end. else do:
      for each ub.dis-gds-rule no-lock where
              ub.dis-gds-rule.discnt-role = v-discnt-role
          and ub.dis-gds-rule.obj-type = v-obj-type
          and ub.dis-gds-rule.obj-code = v-obj-code,
          first ub.goods no-lock where
                ub.goods.gds-code = ub.dis-gds-rule.gds-code:
        if rs-list-method = "dis-gds-rule-num" then do:
          if ub.dis-gds-rule.rule-num <> vvalue-int then NEXT.
        end. /*if rs-list-method = */
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end. /*for each dis-gds-rule*/
      {&assign-nums}.
    end.
  end. /*when "dis-gds-rule" ...*/
  when "gds-obj-attr" or when "gds-obj-attr-val"  then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U no-error .
    assign
    v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
    v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
    v-attr-code = entry(3, buf_{1}-hist.item_, {&delim-key})
    vvalue = (if rs-list-method = "gds-obj-attr" then '':U else entry(4, buf_{1}-hist.item_, {&delim-key}))
    no-error
    .
    if error-status:error then do: end. else do:
      for each ub.gds-obj-attr no-lock where
              ub.gds-obj-attr.obj-type = v-obj-type
            and ub.gds-obj-attr.obj-code = v-obj-code
            and ub.gds-obj-attr.attr-code = v-attr-code,
          first ub.goods no-lock where
                ub.goods.gds-code = ub.gds-obj-attr.gds-code:
        if rs-list-method = "gds-obj-attr-val" then do:
          run gdsoattr-value  in this-procedure (
                                                 input v-attr-code
                                                ,input gds-obj-attr.gds-code
                                                ,input gds-obj-attr.obj-type
                                                ,input gds-obj-attr.obj-code
                                                ,output vvalue1
                                                ,output vtype).
          if vvalue1 <> vvalue then NEXT.
        end. /*if rs-list-method = */
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end. /*for each gds-obj*/
      {&assign-nums}.
    end.
  end. /*when "gds-obj-attr" ...*/
  when "gds-host-attr"
  or
  when "gds-host-attr-val" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U .
    assign
    v-host-code = integer(entry(1, buf_{1}-hist.item_, {&delim-key}))
    v-attr-code = entry(2, buf_{1}-hist.item_, {&delim-key})
    vvalue = (if rs-list-method = "gds-host-attr" then '':U else entry(3, buf_{1}-hist.item_, {&delim-key}))
    no-error
    .
    if error-status:error then do: end. else do:
      for each  ub.gds-host-attr no-lock where
              ub.gds-host-attr.host-code = v-host-code:
        if ub.gds-host-attr.attr-code <> v-attr-code then NEXT.
        find first ub.goods no-lock where
                  ub.goods.gds-code = ub.gds-host-attr.gds-code no-error .
        if available ub.goods then do:
          if rs-list-method = "gds-host-attr-val" then do:
            run gdshattr-h-value  in this-procedure(
                                                    input v-attr-code
                                                    ,input v-host-code
                                                    ,input ub.gds-host-attr.gds-code
                                                    ,output vvalue1
                                                    ,output vtype).
            if vvalue1 <> vvalue then NEXT.
          end. /*if rs-list-method = */
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end. /*for each gds-host*/
      {&assign-nums}.
    end.
  end. /*when "gds-host-attr" ...*/
  when "goods-attr"
  or
  when "goods-attr-val"
  then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U .
    assign
    v-attr-code = entry(1, buf_{1}-hist.item_, {&delim-key})
    vvalue = (if rs-list-method = "goods-attr" then '':U else entry(2, buf_{1}-hist.item_, {&delim-key}))
    no-error
    .
    if error-status:error then do: end. else do:
      for each  ub.goods-attr no-lock where
              ub.goods-attr.attr-code = v-attr-code,
          first ub.goods no-lock where
                  ub.goods.gds-code = ub.goods-attr.gds-code:
        if rs-list-method = "goods-attr-val" then do:
          run gds-attr-value in this-procedure (
                               input ub.goods-attr.gds-code
                              ,input v-attr-code
                              ,output vvalue1
                              ,output vtype).
          if vvalue1 <> vvalue then NEXT.
        end. /*if rs-list-method = */
        run ex-gds  in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end. /*for each gds-host*/
      {&assign-nums}.
    end.
  end. /*when "goods-attr" ...*/
  when "tax-rate-value" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U .
    assign
    v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
    v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
    v-date = date(entry(3, buf_{1}-hist.item_, {&delim-key}))
    v-attr-code = entry(4, buf_{1}-hist.item_, {&delim-key})
    vvalue = entry(5, buf_{1}-hist.item_, {&delim-key})
    no-error
    .
    if error-status:error then do: end. else do:
      { gbl/hostcode.i v-obj-type v-obj-code v-host-code }
      for each ub.goods no-lock:
        if lookup({&vat-tax-code}, v-attr-code, {&delim-par}) > 0 then do:
          { gbl/pftxvalg.i ub.goods.gds-code {&vat-tax-code} v-date v-host-code v-obj-type v-obj-code vvaluedec no-error }
          if vvaluedec <> decimal(entry(lookup({&vat-tax-code}, v-attr-code, {&delim-par}), vvalue, {&delim-par})) then NEXT.
        end.
        if lookup({&slt-tax-code}, v-attr-code, {&delim-par}) > 0 then do:
          { gbl/pftxvalg.i ub.goods.gds-code {&slt-tax-code} v-date v-host-code v-obj-type v-obj-code vvaluedec no-error }
          if vvaluedec <> decimal(entry(lookup({&slt-tax-code}, v-attr-code, {&delim-par}), vvalue, {&delim-par})) then NEXT.
        end.
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end. /*for each goods*/
      {&assign-nums}.
    end.
  end. /*when "tax-rate-value" ...*/
  when "tax-rate-value-obj" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U .
    assign
    v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
    v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
    v-date = date(entry(3, buf_{1}-hist.item_, {&delim-key}))
    v-attr-code = entry(4, buf_{1}-hist.item_, {&delim-key})
    vvalue = entry(5, buf_{1}-hist.item_, {&delim-key})
    no-error
    .
    if error-status:error then do: end. else do:
      { gbl/hostcode.i v-obj-type v-obj-code v-host-code }
      for each ub.gds-obj no-lock where
                  ub.gds-obj.obj-type = v-obj-type
              AND ub.gds-obj.obj-code = v-obj-code,
              first ub.goods no-lock where
                    ub.goods.gds-code = ub.gds-obj.gds-code:
        if lookup({&vat-tax-code}, v-attr-code, {&delim-par}) > 0 then do:
          { gbl/pftxvalg.i ub.goods.gds-code {&vat-tax-code} v-date v-host-code v-obj-type v-obj-code vvaluedec no-error }
          if vvaluedec <> decimal(entry(lookup({&vat-tax-code}, v-attr-code, {&delim-par}), vvalue, {&delim-par})) then NEXT.
        end.
        if lookup({&slt-tax-code}, v-attr-code, {&delim-par}) > 0 then do:
          { gbl/pftxvalg.i ub.goods.gds-code {&slt-tax-code} v-date v-host-code v-obj-type v-obj-code vvaluedec no-error }
          if vvaluedec <> decimal(entry(lookup({&slt-tax-code}, v-attr-code, {&delim-par}), vvalue, {&delim-par})) then NEXT.
        end.
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end. /*for each gds-obj*/
      {&assign-nums}.
    end.
  end. /*when "tax-rate-value-obj" ...*/
  when "ov-req" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U .
    {&get-rowid} do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj no-lock
        where ub.gds-obj.obj-type = v-user-obj-type
          and ub.gds-obj.obj-code = v-user-obj-code
          and ub.gds-obj.in-ov    = yes,
          first ub.goods no-lock
        where ub.goods.prod-type = ub.gds-obj.prod-type
          and ub.goods.prod-code = ub.gds-obj.prod-code
          and ub.goods.artic     = ub.gds-obj.artic:
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end.
  end.
  when "inv-req" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U .
    {&get-rowid} do: end. else do:
      run find-user-obj-rowid in this-procedure ( input v-rowid, input v-no-context, output v-user-obj-type, output v-user-obj-code ).
      for each ub.gds-obj where ub.gds-obj.obj-type = v-user-obj-type
                        and ub.gds-obj.obj-code = v-user-obj-code no-lock,
          first ub.goods where ub.goods.prod-type = ub.gds-obj.prod-type
                        and ub.goods.prod-code = ub.gds-obj.prod-code
                        and ub.goods.artic = ub.gds-obj.artic no-lock:
        find last ub.doc-line where ub.doc-line.prod-type = goods.prod-type
                            and ub.doc-line.prod-code = goods.prod-code
                            and ub.doc-line.artic = goods.artic
                            and ub.doc-line.obj-type = v-user-obj-type
                            and ub.doc-line.obj-code = v-user-obj-code
                            and ub.doc-line.status_ = {&fact}
                            use-index fact-order no-lock no-error.
        if available ub.doc-line and
          can-find (ub.trn-doc where ub.trn-doc.doc-code = ub.doc-line.doc-code and ub.trn-doc.doc-type <> {&inventory} no-lock) then
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end.
      {&assign-nums}.
    end.
  end.
  when "scales-gds" or when "scales-gds-num"  then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U no-error .
    assign
    v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
    v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
    vvalue = (if rs-list-method = "scales-gds" then '':U else entry(3, buf_{1}-hist.item_, {&delim-key}))
    no-error
    .
    if error-status:error then do: end. else do:
      for each ub.scales-gds no-lock where
              ub.scales-gds.obj-type = v-obj-type
            and ub.scales-gds.obj-code = v-obj-code,
          first ub.bar-code no-lock where
                ub.bar-code.b-code = ub.scales-gds.b-code,
          first ub.goods no-lock where
                ub.goods.gds-code = bar-code.b-code:
        if rs-list-method = "scales-gds-num" then do:
          if ub.scales-gds.scales-num <> integer( vvalue) then NEXT.
        end. /*if rs-list-method = */
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      end. /*for each gds-obj*/
      {&assign-nums}.
    end.
  end. /*when "scales-gds" or when "scales-gds-num"  then do*/
  when "parts-last-date" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U no-error .
    assign
    v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
    v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
    vvalue-int = integer(entry(3, buf_{1}-hist.item_, {&delim-key}))
    no-error
    .
    if error-status:error then do: end. else do:
      for each buf_parts no-lock where
              buf_parts.obj-type = v-obj-type
            and buf_parts.obj-code = v-obj-code
            and buf_parts.out-code  = {&free-code}
            and buf_parts.status_   = false:
        if buf_parts.last-date <> ?
        and (buf_parts.last-date - today) < vvalue-int then do:
          find first goods no-lock where
                goods.artic = buf_parts.artic
            and goods.prod-type = buf_parts.prod-type
            and goods.prod-code = buf_parts.prod-code no-error.
          if available goods then do:
            run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
            {&assign-nums}.
          end.
        end. /*      if buf_parts.last-date - today < vvalue-int then do:*/
      end. /*for each buf_parts*/
    end.
  end. /*when "parts-last-date"  then do*/
  when "parts-fib" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U no-error .
    assign
    v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
    v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
    no-error
    .
    if error-status:error then do: end. else do:
      for each buf_parts no-lock where
              buf_parts.obj-type = v-obj-type
            and buf_parts.obj-code = v-obj-code
            and buf_parts.out-code  = {&free-code}
            and buf_parts.status_   = false:
        if buf_parts.defect = logical({&FiB}) then do:
          find first goods no-lock where
                goods.artic = buf_parts.artic
            and goods.prod-type = buf_parts.prod-type
            and goods.prod-code = buf_parts.prod-code no-error.
          if available goods then do:
            run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
            {&assign-nums}.
          end.
        end. /*      if buf_parts.defect*/
      end. /*for each buf_parts*/
    end.
  end. /*when "parts-fib"  then do*/
  when "cashparts":U  then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U no-error .
    assign
    v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
    v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
    no-error
    .
    if error-status:error then do: end. else do:
      for each ub.gds-obj no-lock where
              ub.gds-obj.obj-type = v-obj-type
            and ub.gds-obj.obj-code = v-obj-code
            and ub.gds-obj.cash-parts:
        /*уже есть индекс по cash-parts*/
        find first goods no-lock where
              goods.artic = ub.gds-obj.artic
          and goods.prod-type = ub.gds-obj.prod-type
          and goods.prod-code = ub.gds-obj.prod-code no-error.
        if available goods then do:
          run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
          {&assign-nums}.
        end.
      end. /*for each buf_parts*/
    end.
  end. /*when "parts-cahsparts":U then do:*/
  when "doc-list"
  or
  when "prod-list"
  or
  when "supp-list"
  or
  when "cli-list"
  or
  when "scaner"
  or
  when "file"
  or
  when "clob-data"
  then do:
    run proc-file-list-methods in this-procedure(input p-from-macro, input rs-list-method, input rs-status, input line-mode, input p-id). .
  end. /*все по файлам*/
  when "deleted" then do:
    find first buf_{1}-hist where
              buf_{1}-hist.id = p-id.
    for each ub.goods where ub.goods.stts > 0 no-lock:
      run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
    end.
    {&assign-nums}.
  end.
  when "filter" then do:
    define variable v-filter-var as character no-undo .
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U .
    run proc-write-filter-expression-var in this-procedure ( input buf_{1}-hist.item_, output v-filter-var ).
    &if "{1}" = "scn-list" &then
    run gbl/scn-fill.p (
    &else
      &if "{1}" = "gds-list" &then
      run gbl/gds-fill.p (
      &else
      run gbl/gdf-fill.p (
      &endif
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
    when "no-recipe-gds":U then do:
     for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid}  next.
      grp-path = "".
      find first gds-grp no-lock where rowid(gds-grp) = v-rowid.
      run grplib-get-full-name in this-procedure (gds-grp.node-code, output grp-path).
      goods:
      for each goods where goods.grp-name begins grp-path no-lock,
          each recipe no-lock where recipe.artic = ub.goods.artic
                        and recipe.prod-type = ub.goods.prod-type
                        and recipe.prod-code = ub.goods.prod-code :
          for each recipe-gds where recipe-gds.recipe-code = recipe.recipe-code no-lock:
              
          if can-find(first gds-obj no-lock where gds-obj.obj-type = v-cntxt-obj-type  
                                  and gds-obj.obj-code = v-cntxt-obj-code
                                  and gds-obj.gds-code = recipe-gds.gds-code
                                  and gds-obj.fact-qnty > 0) then.
          else do:                                               
                run ex-gds  in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
                next goods.
            end.    
          end.
      end.
      {&assign-nums}.
     end.
  end.
  when "move-date":U then do:
      find first buf_{1}-hist where
          buf_{1}-hist.id = p-id
      AND buf_{1}-hist.item_ <> '':U .
      for each gds-obj  no-lock where gds-obj.obj-type = v-cntxt-obj-type  
                                  and gds-obj.obj-code = v-cntxt-obj-code
                                  and gds-obj.last-doc >= date(buf_{1}-hist.item_):
          for first goods no-lock where
                goods.artic = ub.gds-obj.artic
            and goods.prod-type = ub.gds-obj.prod-type
            and goods.prod-code = ub.gds-obj.prod-code:
            run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
            {&assign-nums}.
          end.
      end.
  end.
end.
dsp-rs:fgcolor in frame {&frame-name} = 4.
if session:set-wait-state( "" )  then .
case line-mode :
  when {&add-def} then do:
    tot-lns = tot-lns + lns-cnt.
    &if "{2}" <> "pre-macro" &then
    if not p-from-macro or p-step then
    message
    "Добавлено строк :" lns-cnt skip(0)
    string(if lns-ignore <> 0
    then ("Проигнорировано строк :" + string(lns-ignore))
    else "":U)
    .
    &endif
  end.
  when {&deletion} then do:
    tot-lns = tot-lns - lns-cnt.
    &if "{2}" <> "pre-macro" &then
    if not p-from-macro or p-step then
    message
    "Удалено строк :" lns-cnt skip(0)
    string(if lns-ignore <> 0
    then ("Проигнорировано строк :" + string(lns-ignore))
    else "":U)
    .
    &endif
  end.
end.
if line-mode <> {&leave} then  run UI-on in this-procedure.
end. /*doe*/
END PROCEDURE.

PROCEDURE write-hist :
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define variable v-ii as integer no-undo .
define variable v-temp-seq as integer no-undo .
/* запись истории формирования списка */
if rs-list-method = "single" then do:
  if v-no-hist < 0 then do:
    run create-{1}-hist in this-procedure(input {&add-def}
                                        , input-output v-seq
                                        , input 0
                                        , input get-hist-mode(line-mode)
                                        , input substitute("ТОВАР код &1 &2 &3&4 &5", {1}.gds-code, {1}.artic, {1}.prod-type, {1}.prod-code, {1}.gds-name)
                                        , input tot-lns
                                        , input rs-list-method
                                        , input rs-status
                                        , input ('goods':U + {&delim-key} + string({1}.gds-code))
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
                                          , input substitute("ТОВАР код &1 &2 &3&4 &5", {1}.gds-code, {1}.artic, {1}.prod-type, {1}.prod-code, {1}.gds-name)
                                          , input tot-lns
                                          , input '':U
                                          , input '':U
                                          , input ('goods':U + {&delim-key} + string({1}.gds-code))
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
END PROCEDURE.

procedure list_inf-local:
define variable glog as logical no-undo .
for each tt-goods:
  delete tt-goods.
end.
for each tt-clients:
  delete tt-clients.
end.
for each {1}:
find ub.goods where ub.goods.artic     = {1}.artic     and
                ub.goods.prod-type = {1}.prod-type and
                ub.goods.prod-code = {1}.prod-code no-lock.
    create tt-goods.
    buffer-copy ub.goods to tt-goods.
end.
create tt-clients.
assign tt-clients.obj-type = p-curr-obj-type
      tt-clients.obj-code = p-curr-obj-code.
{&net-proc}
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_reference_archive':U
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
if glog then run arc/gds_inf.w
(input  parparentproc
,input  v-cntxt-obj-type
,input  v-cntxt-obj-code ).

end procedure.

FUNCTION stat-line RETURNS CHARACTER(input p-status-chr as character):
/*функция возвращает строку для message и для dsp-rs*/
DEFINE VARIABLE var-stat-line as character no-undo .

CASE p-status-chr:
  when {&all} then do:
    assign
    var-stat-line = "(текущие и неактивные товары)"
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
define variable glog as logical no-undo .
define variable ii as integer no-undo .
define variable v-recs as integer no-undo .
define variable v-line as integer no-undo .
define variable v-item as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-tot-lns as integer no-undo .
define variable v-grp-rec as recid no-undo .
define variable v-ref-rec as recid no-undo .
define variable v-dopstr as character no-undo .
define variable v-input-output as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-temp-seq as integer no-undo .
define variable v-message as character no-undo .
define variable grp-path as character no-undo .
define variable v-rid-list as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_{1}-hist for {1}-hist.
define buffer buf_clob-bind for ub.clob-bind.

do
on error undo, return error
:
  v-no-hist = - 1.
  if temp-list.fvalue = "single" then
  run UI-on in this-procedure.
  else do:
    v-no-hist = 0.
    case rs-list-method:
      when "all" then do:
        glog = yes.
        message "Все товары из справочника товаров"
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error .
        end.
        v-no-hist = 1.
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute('Все товары &1', stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input 'all':U
                                            , input '':U
                                            , input ?
                                            ).
      end. /*when all*/
      when "gds-grp" or
      when "goods" or
      when "gds-obj":U or
      when "gds-obj-fact":U or
      when "gds-obj-free":U or
      when "no-recipe-gds":U
      then do:
        if rs-list-method = "gds-grp" or rs-list-method = "no-recipe-gds" then do:
          glog = yes.
          message "1 или несколько групп товаров"
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on in this-procedure.
            return error.
          end.
          /* вызов справочника групп товаров для выбора */
          grp-list = "". /* кажется, при выходе по Esc не снимается */
          ref-list = "".
          run ref/gds-grp.w (input parparentproc
                        ,input "b-sel,b-mark"
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input-output grp-list).
        end.
        else do:
          glog = yes.
          message "1 или несколько произвольных товаров из справочника."
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on in this-procedure.
            return error.
          end.
          run ref/gds-ref.p ( parparentproc
                          ,"b-sel,b-mark,b-add"
                          ,?                      /*p-stat */
                          ,?                      /*p-list  */
                          ,(if rs-list-method = "goods"
                            then {&all}
                            else (if rs-list-method = "gds-obj":U
                                  then {&g___object}
                                  else (if rs-list-method = "gds-obj-fact":U
                                        then {&fact}
                                        else (if rs-list-method = "gds-obj-free":U
                                              then {&free}
                                              else ?
                                              )
                                        )
                                  )
                          )
                          /*p-cond  */
                          ,?                      /*p-rec   */
                          ,?                      /*p-grp   */
                          ,?                      /*p-cli-type */
                          ,?                      /*p-cli-code  */
                          ,p-curr-obj-type             /*p-obj-type  */
                          ,p-curr-obj-code              /*p-obj-code  */
                          ,?                      /*p-other     */
                          , output ref-list).
          grp-list = ?.
        end.
        if grp-list <> ? and
        grp-list <> "" then do:
          v-recs = num-entries (grp-list).
          do num-rec = 0 to v-recs:
            if v-recs = 1 then do:
              num-rec = 1 .
            end.
            if num-rec > 0 then do:
              v-grp-rec = integer (entry (num-rec, grp-list)).
              find ub.gds-grp where recid (ub.gds-grp) = v-grp-rec no-lock.
              run grplib-get-full-name in this-procedure (ub.gds-grp.node-code, output grp-path).
            end.
            if v-recs = 1 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Группа : &1 &3", grp-path, stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = {&table_gds-grp}
              v-bh       = buffer ub.gds-grp:handle
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then do:
                assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Группы : &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
                .
              end.
              else do:
                assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("&1", grp-path)
                v-item     = '':U
                v-tbl-name = {&table_gds-grp}
                v-bh       = buffer ub.gds-grp:handle
                v-tot-lns = tot-lns + num-rec
                .
              end.
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            run create-{1}-hist in this-procedure(input {&add-def}
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
          end. /*do num-rec*/
        end. /*группы*/
        else if ref-list <> "" then do:
          v-recs = num-entries (ref-list).
          do num-rec = 0 to v-recs:
            if v-recs = 1 then do:
              num-rec = 1 .
            end.
            if num-rec > 0 then do:
              v-ref-rec = integer (entry (num-rec, ref-list)).
              find ub.goods where recid (ub.goods) = v-ref-rec no-lock.
            end.
            if v-recs = 1 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Товар :&1 &2", ub.goods.gds-name, stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = {&table_goods}
              v-bh       = buffer goods:handle
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then do:
                assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Товары : &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
                .
              end.
              else do:
                assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("код &1 &2 &3&4 &5", goods.gds-code, goods.artic, goods.prod-type, goods.prod-code, goods.gds-name)
                v-item     = '':U
                v-tbl-name = {&table_goods}
                v-bh       = buffer ub.goods:handle
                v-tot-lns = tot-lns + num-rec
                .
              end.
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            run create-{1}-hist in this-procedure(input {&add-def}
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
          end. /*do num-rec*/
        end.
        else do:
          run UI-on in this-procedure.
          return error.
        end.
      end.
      when "grp-prod" or
      when "producer" then do:
        if rs-list-method = "grp-prod" then do:
          glog = yes.
          message "товары по производителям из 1 или нескольких групп."
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on in this-procedure.
            return error.
          end.
          /* вызов справочника групп клиентов для выбора */
          grp-list = "". /* кажется, при выходе по Esc не снимается */
          ref-list = "".
          run ref/cli-grps.w ( input parparentproc
                              ,input "b-sel,b-mark"
                              ,input-output grp-list).
        end.
        else do:
          glog = yes.
          message "товары по 1 или нескольким производителям из справочника."
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on in this-procedure.
            return error.
          end.
          grp-list = "". /* чтоб не было ложного срабатывания следующего if */
          run ref/cli-all.w ( parparentproc
                        ,"b-sel,b-mark"
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , output ref-list) .
        end.
        if grp-list <> ? and
        grp-list <> "" then do:
          v-recs = num-entries (grp-list).
          do num-rec = 0 to v-recs:
            if v-recs = 1 then do:
              num-rec = 1 .
            end.
            if num-rec > 0 then do:
              v-grp-rec = integer (entry (num-rec, grp-list)).
              find ub.cli-grp where recid (ub.cli-grp) = v-grp-rec no-lock.
              run cli-grplib-get-full-name in this-procedure (ub.cli-grp.node-code, output grp-path).
            end.
            if v-recs = 1 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Группа пр-лей: &1 &2", grp-path, stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = {&table_cli-grp}
              v-bh       = buffer cli-grp:handle
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then do:
                assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Группы пр-лей: &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
                .
              end.
              else do:
                assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("&1", grp-path)
                v-item     = '':U
                v-tbl-name = {&table_cli-grp}
                v-bh       = buffer cli-grp:handle
                v-tot-lns = tot-lns + num-rec
                .
              end.
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            run create-{1}-hist in this-procedure(input {&add-def}
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
          end.
        end.
        else if ref-list <> "" and  ref-list <> ? then do:
          v-recs = num-entries (ref-list) .
          do num-rec = 0 to v-recs:
            if v-recs = 1 then do:
              num-rec = 1 .
            end.
            if num-rec > 0 then do:
              v-ref-rec = integer (entry (num-rec, ref-list)).
              find ub.clients where recid (ub.clients) = v-ref-rec no-lock.
            end.
            if v-recs = 1 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Производитель :&1 &2", clients.obj-name, stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = {&table_clients}
              v-bh       = buffer ub.clients:handle
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then do:
                assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Производитель : &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
                .
              end.
              else do:
                assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("&1", clients.obj-name)
                v-item     = '':U
                v-tbl-name = {&table_clients}
                v-bh       = buffer ub.clients:handle
                v-tot-lns = tot-lns + num-rec
                .
              end.
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            run create-{1}-hist in this-procedure(input {&add-def}
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
          end. /*do num-rec*/
        end.
        else do:
          run UI-on in this-procedure.
          return error.
        end.
      end.
      /*-------------------------------------------------------*/
      when "choose-alc-prod" then do:
          grp-list = "". /* чтоб не было ложного срабатывания следующего if */
          run ref/alc-type.w ( input parparentproc
                              ,input "b-sel,b-mark"
                              ,input-output grp-list
                              ,output v-ok ).

        if grp-list <> ? and
        grp-list <> "" then do:
          v-recs = num-entries (grp-list).
          do num-rec = 0 to v-recs:
            if v-recs = 1 then do:
              num-rec = 1 .
            end.
            if num-rec > 0 then do:
              v-grp-rec = integer (entry (num-rec, grp-list)).
              find ub.alc-type where recid (ub.alc-type) = v-grp-rec no-lock.
              run grplib-get-full-name-alc-type in this-procedure (ub.alc-type.alc-type-inner-code, output grp-path).
            end.
            if v-recs = 1 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Вид алкогольной продукции: &1 &2", grp-path, stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = {&table_alc-type}
              v-bh       = buffer ub.alc-type:handle
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then do:
                assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Виды алкогольной продукции: &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
                .
              end.
              else do:
                assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("&1", grp-path)
                v-item     = '':U
                v-tbl-name = {&table_alc-type}
                v-bh       = buffer alc-type:handle
                v-tot-lns = tot-lns + num-rec
                .
              end.
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            run create-{1}-hist in this-procedure(input {&add-def}
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
          end.
        end.
      end.
      /*-------------------------------------------------------*/
      when "grp-supp" or
      when "supplier" then do:
        if rs-list-method = "grp-supp" then do:
          glog = yes.
          message "товары по поставщикам из 1 или нескольких групп."
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on in this-procedure.
            return error.
          end.
          /* вызов справочника групп клиентов для выбора */
          grp-list = "". /* кажется, при выходе по Esc не снимается */
          ref-list = "".
          run ref/cli-grps.w ( input parparentproc
                              ,input "b-sel,b-mark"
                              ,input-output grp-list).
        end.
        else do:
          glog = yes.
          message "товары по 1 или нескольким поставщикам из справочника."
          skip stat-line(rs-status)
          view-as alert-box question buttons OK-Cancel update glog.
          if not glog then do:
            run UI-on in this-procedure.
            return error.
          end.
          grp-list = "". /* чтоб не было ложного срабатывания следующего if */
          run ref/cli-all.w (parparentproc
                        , "b-sel,b-mark"
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , output ref-list) .
        end.
        if grp-list <> ? and
        grp-list <> "" then do:
          v-recs = num-entries (grp-list).
          do num-rec = 0 to v-recs:
            if v-recs = 1 then do:
              num-rec = 1 .
            end.
            if num-rec > 0 then do:
              v-grp-rec = integer (entry (num-rec, grp-list)).
              find cli-grp where recid (cli-grp) = v-grp-rec no-lock.
              run cli-grplib-get-full-name in this-procedure (cli-grp.node-code, output grp-path).
            end.
            if v-recs = 1 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Группа поставщиков: &1 &2", grp-path, stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = {&table_cli-grp}
              v-bh       = buffer cli-grp:handle
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then do:
                assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Группы поставщиков: &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
                .
              end.
              else do:
                assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("&1", grp-path)
                v-item     = '':U
                v-tbl-name = {&table_cli-grp}
                v-bh       = buffer cli-grp:handle
                v-tot-lns = tot-lns + num-rec
                .
              end.
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            run create-{1}-hist in this-procedure(input {&add-def}
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
          end.
        end.
        else if ref-list <> "" and ref-list <> ? then do:
          v-recs = num-entries (ref-list).
          do num-rec = 0 to v-recs:
            if v-recs = 1 then do:
              num-rec = 1 .
            end.
            if num-rec > 0 then do:
              v-ref-rec = integer (entry (num-rec, ref-list)).
              find clients where recid (clients) = v-ref-rec no-lock.
            end.
            if v-recs = 1 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Поставщик :&1 &2", clients.obj-name, stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = {&table_clients}
              v-bh       = buffer clients:handle
              v-tot-lns = tot-lns
              .
            end.
            else do:
              if num-rec = 0 then do:
                assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Поставщики : &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
                .
              end.
              else do:
                assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("&1", clients.obj-name)
                v-item     = '':U
                v-tbl-name = {&table_clients}
                v-bh       = buffer clients:handle
                v-tot-lns = tot-lns + num-rec
                .
              end.
            end.
            v-no-hist = (if num-rec = 1 then 0 else num-rec).
            run create-{1}-hist in this-procedure(input {&add-def}
                                                , input-output v-temp-seq
                                                , input v-line
                                                , input '':U
                                                , input dsp-rs
                                                , input v-tot-lns
                                                , input rs-list-method
                                                , input rs-status
                                                , input v-item
                                                , input v-tbl-name
                                                , input v-bh
                                                ).
            if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
          end. /*do num-rec*/
        end.
        else do:
          run UI-on in this-procedure.
          return error.
        end.
      end.
      when "waybill" then do:
        glog = yes.
        message "Все товары из документов (накладных)."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run str/all-docs.w (input parparentproc
                      ,input (if v-docs-all
                             then ?
                             else v-cntxt-host-code-obj)
                      ,input (if v-docs-all
                             then ?
                             else v-cntxt-obj-type)
                      ,input (if v-docs-all
                             then ?
                             else v-cntxt-obj-code)
                      ,input (if v-docs-all
                              then {&work}
                              else (if v-docs-cmp
                                   then {&company}
                                   else {&g___object})
                              )
                      ,input ? /*parstat*/
                      ,input ? /*partype*/
                      ,input ? /*parflag*/
                      ,input ? /*parinternal*/
                      ,input 'b-sel,b-mark':U /*bttns*/
                      ,input '':U /*parext-doc-type*/
                      ,input ? /*paris-hold*/
                      ,input ? /*doc-rec*/
                      ,output ref-list
                      ) no-error .
        &if "{1}" = "scn-list" &then
        run str/sortdctp.p ( input-output ref-list, input no).
        &endif
        if ref-list = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        v-recs = num-entries(ref-list).
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, ref-list)).
            find ub.trn-doc where recid (ub.trn-doc) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Документ : &1 &2 &3 &4 № &5 от &6 &7"
                                , ub.trn-doc.doc-type
                                , ub.trn-doc.status_
                                , ub.trn-doc.obj-type
                                , ub.trn-doc.obj-code
                                , ub.trn-doc.doc-code
                                , string (ub.trn-doc.doc-date, '99/99/9999')
                                , stat-line(rs-status)
                                )
            v-item     = '':U
            v-tbl-name = {&table_trn-doc}
            v-bh       = buffer ub.trn-doc:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Документы : &1", stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
            end.
            else do:
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1 &2 &3 &4 № &5 от &6"
                                  , ub.trn-doc.doc-type
                                  , ub.trn-doc.status_
                                  , ub.trn-doc.obj-type
                                  , ub.trn-doc.obj-code
                                  , ub.trn-doc.doc-code
                                  , string (ub.trn-doc.doc-date, '99/99/9999')
                                  )
              v-item     = '':U
              v-tbl-name = {&table_trn-doc}
              v-bh       = buffer ub.trn-doc:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input v-tbl-name
                                              , input v-bh
                                              ).
          if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        end. /*do num-rec*/
      end.
      when "manufacture" then do:
        glog = yes.
        message "Все товары из 1 документа производства."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        ref-list = '':U.
        run str/fbr-docs.w ( input parparentproc
                            ,input  ?
                            ,input (if v-docs-all
                                    then {&work}
                                    else {&g___object}
                                    )
                           ,input-output ref-list).
        if ref-list = '':u then do:
          run UI-on in this-procedure.
          return error.
        end.
        v-doc-rec = integer(entry(1, ref-list)).
        if v-doc-rec = ? then do:
          run UI-on in this-procedure.
          return error.
        end.
        find ub.fbr-doc where recid (ub.fbr-doc) = v-doc-rec no-lock.
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input  substitute("Производство : &1 &2 &3 № &4 от &5 &7"
                                                                  ,fbr-doc.status_
                                                                  ,fbr-doc.obj-type
                                                                  ,fbr-doc.obj-code
                                                                  ,fbr-doc.doc-code
                                                                  ,string (fbr-doc.doc-date, '99/99/9999')
                                                                  , stat-line(rs-status)
                                                                  )
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input '':U
                                              , input {&table_fbr-doc}
                                              , input buffer ub.fbr-doc:handle
                                              ).
      end.
      when "recipe" then do:
        glog = yes.
        message "Все товары из 1 рецепта."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run ref/rcp-all.w (
            input parparentproc
          , input "b-sel"
          , input {&all}
          , input ?
          , input p-curr-obj-type
          , input p-curr-obj-code
          , output ref-list
        ).
        if ref-list = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        find ub.recipe where recid (ub.recipe) = integer (ref-list) no-lock.
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Товары рецепта : &1 &2 Артикул &3 &4"
                                                              , ub.recipe.recipe-code
                                                              , ub.recipe.recipe-name
                                                              , ub.recipe.artic
                                                              , stat-line(rs-status)
                                                              )
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input '':U
                                            , input {&table_recipe}
                                            , input buffer ub.recipe:handle
                                            ).
      end.
      when "self-recipe" then do:
        glog = yes.
        message "Товар с рецептом."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run ref/rcp-all.w (
            input parparentproc
          , input "b-sel"
          , input {&all}
          , input ?
          , input p-curr-obj-type
          , input p-curr-obj-code
          , output ref-list
        ).
        if ref-list = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        find ub.recipe where recid (ub.recipe) = integer (ref-list) no-lock.
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Рецепт : &1 &2 Артикул &3 &4"
                                                              , ub.recipe.recipe-code
                                                              , ub.recipe.recipe-name
                                                              , ub.recipe.artic
                                                              , stat-line(rs-status)
                                                              )
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input '':U
                                            , input {&table_recipe}
                                            , input buffer ub.recipe:handle
                                            ).
      end.
      when "contract" then do:
        glog = yes.
        message "Все товары из спецификаций договоров."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        ref-list = '' .
        run str/cont-all.w (
            input parparentproc
          , input p-curr-host-code
          , input "b-sel,b-mark"
          , input {&all}
          , input ?
          , input ?
          , input ?
          , input ?
          , input "current":U
          , input "all":U
          , input-output ref-list ) .

        if ref-list = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        v-recs = num-entries(ref-list).
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, ref-list)).
            find ub.contract where recid (ub.contract) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Договор : &1 (&2) &3",
                                   ub.contract.contract-code
                                   ,ub.contract.contract-prn-code
                                   , stat-line(rs-status) )
              v-item     = '':U
              v-tbl-name = {&table_contract}
              v-bh       = buffer ub.contract:handle
              v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
                v-temp-seq = v-seq
                v-line     = 0
                dsp-rs = substitute("Договоры : &1", stat-line(rs-status))
                v-item     = '':U
                v-tbl-name = '':U
                v-bh       = ?
                v-tot-lns = tot-lns
              .
            end.
            else do:
              assign
                v-temp-seq = v-seq - 1
                v-line     = num-rec
                dsp-rs = substitute("&1 (&2) &3"
                                     ,ub.contract.contract-code
                                     ,ub.contract.contract-prn-code
                                     , stat-line(rs-status) )
                v-item     = '':U
                v-tbl-name = {&table_contract}
                v-bh       = buffer ub.contract:handle
                v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input v-tbl-name
                                              , input v-bh
                                              ).
          if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        end. /*do num-rec*/
      end.
      when "overvalue" then do:
        glog = yes.
        message "Все товары из выбранных переоценок (акта или приказа)."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run str/pr-docs.w (
           input parparentproc
          ,input "b-sel,b-mark":U
          ,input (if v-docs-all
                then {&work}
                else (if v-docs-cmp
                      then {&company}
                      else {&g___object}
                      )
                )
          ,input ""
          ,input p-curr-obj-type
          ,input p-curr-obj-code
          ,input ""
          ,output ref-list
          ).
        if ref-list = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        /* выбраны переоценки */
        v-recs = num-entries(ref-list).
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, ref-list)).
            find ub.price-doc where recid (ub.price-doc) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Переоценка : &1 &2 &3 № &4 от &5 &6"
                                , ub.price-doc.status_
                                , ub.price-doc.obj-type
                                , ub.price-doc.obj-code
                                , ub.price-doc.doc-num
                                , string(ub.price-doc.doc-date, '99/99/9999')
                                , stat-line(rs-status)
                                )
            v-item     = '':U
            v-tbl-name = {&table_price-doc}
            v-bh       = buffer ub.price-doc:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Переоценки : &1", stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
            end.
            else do:
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("&1 &2 &3 № &4 от &5"
                                  , ub.price-doc.status_
                                  , ub.price-doc.obj-type
                                  , ub.price-doc.obj-code
                                  , ub.price-doc.doc-num
                                  , string(ub.price-doc.doc-date, '99/99/9999')
                                  )
              v-item     = '':U
              v-tbl-name = {&table_price-doc}
              v-bh       = buffer ub.price-doc:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input v-tbl-name
                                              , input v-bh
                                              ).
          if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        end. /*do num-rec*/
      end.
      when "pdf" then do:
        glog = yes.
        message "Все товары из выбранных ДНЦ."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        if v-docs-all then do:
          run str/docsprls.w ( input parparentproc
                            , input  "all"
                            , input ?
                            , input ?
                            , input "b-sel,b-mark"
                            , input-output ref-list) .
        end.
        else do:
          run str/pdfobj.w (  input parparentproc
                             ,input  "all"
                             ,input  v-cntxt-obj-type
                             ,input  v-cntxt-obj-code
                             ,input ?
                             ,input ?
                             ,input "b-sel"
                             ,input-output ref-list) .
        end.
        if ref-list = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        /* выбраны переоценки */
        v-recs = num-entries(ref-list).
        do num-rec = 0 to v-recs:
          if v-recs = 1 then do:
            num-rec = 1 .
          end.
          if num-rec > 0 then do:
            v-ref-rec = integer (entry (num-rec, ref-list)).
            find ub.price-doc-forming where recid (ub.price-doc-forming) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("ДНЦ : ТПЛ &1 (БД &2) № &3 (БД &4) &5"
                                , ub.price-doc-forming.plt-db-num
                                , ub.price-doc-forming.plt-id
                                , ub.price-doc-forming.pdf-db
                                , ub.price-doc-forming.pdf-id
                                , stat-line(rs-status)
                                )
            v-item     = '':U
            v-tbl-name = {&table_price-doc-forming}
            v-bh       = buffer ub.price-doc-forming:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("ДНЦ : &1", stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns = tot-lns
              .
            end.
            else do:
              assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs = substitute("ДНЦ : ТПЛ &1 (БД &2) № &3 (БД &4) &5"
                                  , ub.price-doc-forming.plt-db-num
                                  , ub.price-doc-forming.plt-id
                                  , ub.price-doc-forming.pdf-db
                                  , ub.price-doc-forming.pdf-id
                                  , stat-line(rs-status)
                                  )
              v-item     = '':U
              v-tbl-name = {&table_price-doc-forming}
              v-bh       = buffer ub.price-doc-forming:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input '':U
                                              , input dsp-rs
                                              , input v-tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input v-item
                                              , input v-tbl-name
                                              , input v-bh
                                              ).
          if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
        end. /*do num-rec*/
      end.
      when "abcxyz"
      or
      when "abc-analysis"
      or
      when "xyz-analysis"
      then do:
        run analysis in this-procedure (input rs-list-method) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "collection" then do:
        run collection in this-procedure (input rs-list-method) no-error.
        if error-status:error then do:
          run Ui-on.
          return error.
        end.
      end.

        when "tsd" then 
            do:
                define buffer buf_Code for ub.Code .    
          
                glog = yes.
                message "Загрузить список товаров с ТСД?"
                    skip stat-line(rs-status)
                    view-as alert-box question buttons OK-Cancel update glog.
                if not glog then 
                do:
                    run UI-on in this-procedure.
                    return error.
                end.
                ref-list = "" .
                grp-list = "". /* кажется, при выходе по Esc не снимается */
                ref-list = "".
                num-rec = 0 .
             
                for each buf_Code no-lock where buf_Code.parent = "TiketPrint" and 
                    buf_code.status_ = {&bef-current-status-int}:
                    find first ub.goods no-lock where ub.goods.gds-code = integer(buf_code.code) no-error .
                    if available (ub.goods) then 
                    do:
                        num-rec = num-rec + 1 .

                        if v-recs = 1 then 
                        do:
                            assign
                                v-temp-seq = v-seq
                                v-line     = 0
                                dsp-rs     = substitute("Товар :&1 &2", ub.goods.gds-name, stat-line(rs-status))
                                v-item     = '':U
                                v-tbl-name = {&table_goods}
                                v-bh       = buffer goods:handle
                                v-tot-lns  = tot-lns
                                .
                        end.
                        else 
                        do:
                            if num-rec = 0 then 
                            do:
                                assign
                                    v-temp-seq = v-seq
                                    v-line     = 0
                                    dsp-rs     = substitute("Товары : &1", stat-line(rs-status))
                                    v-item     = '':U
                                    v-tbl-name = '':U
                                    v-bh       = ?
                                    v-tot-lns  = tot-lns
                                    .
                            end.
                            else 
                            do:
                                assign
                                    v-temp-seq = v-seq - 1
                                    v-line     = num-rec
                                    dsp-rs     = substitute("код &1 &2 &3&4 &5", goods.gds-code, goods.artic, goods.prod-type, goods.prod-code, goods.gds-name)
                                    v-item     = '':U
                                    v-tbl-name = {&table_goods}
                                    v-bh       = buffer ub.goods:handle
                                    v-tot-lns  = tot-lns + num-rec
                                    .
                            end.
                        end.
                        v-no-hist = (if num-rec = 1 then 0 else num-rec).
                        run create-{1}-hist in this-procedure(input {&add-def}
                            , input-output v-temp-seq
                            , input v-line
                            , input '':U
                            , input dsp-rs
                            , input v-tot-lns
                            , input rs-list-method
                            , input rs-status
                            , input v-item
                            , input v-tbl-name
                            , input v-bh
                            ).
                        if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
                    end. /*do num-rec*/
                end.
            end.
      when "ass-matr" then do:
        glog = yes.
        message
        "Товары из выбранной ассортиментной матрицы."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        ref-list = '' .
        run ref/assmatr.w (input parparentproc
                    ,input "b-sel":U
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input ""
                    ,input 0
                    ,input-output ref-list).
        if ref-list = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        if num-entries(ref-list) = 1 then do:
          find ub.assortment-matrix where recid (ub.assortment-matrix) = integer(entry(1, ref-list)) no-lock.
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-seq
                                              , input 0
                                              , input '':U
                                              , input  substitute("Ассортиментная матрица : &1 &2"
                                                                  ,ub.assortment-matrix.asmt-name
                                                                  , stat-line(rs-status)
                                                                  )
                                              , input tot-lns
                                              , input rs-list-method
                                              , input rs-status
                                              , input '':U
                                              , input {&table_assortment-matrix}
                                              , input buffer ub.assortment-matrix:handle
                                              ).
        end.
      end.
      when "izt" then do:
        glog = yes.
        message
        "Товары по выбранным ИЖТ."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        /* по текущему объекту */
        v-sel-obj-type =  p-curr-obj-type .
        v-sel-obj-code =  p-curr-obj-code .
          { gbl/uobjsone.i        ~
            parparentproc         ~
            v-cntxt-db-num        ~
            v-cntxt-userid        ~
            v-cntxt-host-code-obj ~
            v-cntxt-obj-type      ~
            v-cntxt-obj-code      ~
            v-user-select         ~
            v-sel-obj-type        ~
            v-sel-obj-code        ~
          }
          if not v-user-select then do:
            return error.
          end.

        run gbl/d-list.w (
            INPUT "b-sel,b-mark":U,
            INPUT "ИЖТ",
            INPUT {&ass-izd-list},
            INPUT {&ass-izd-list} ,
            INPUT  ","          ,
            INPUT  ""           ,
            OUTPUT list-abcxyz  ).

        if list-abcxyz = "" then do:
          run UI-on in this-procedure.
          return error.
        end.
        assign
        dsp-rs = substitute ("Индикаторы жизнедеятельности товара : &1 &2&3 &4&5"
                           , list-abcxyz
                           , v-sel-obj-type
                           , v-sel-obj-code
                           , {&new-line}
                           , stat-line(rs-status))
        v-item = list-abcxyz + {&delim-key} + v-sel-obj-type + {&delim-key} + string(v-sel-obj-code) + {&delim-key}
        .
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
      end.
      when "ass-min" then do:
        glog = yes.
        message
        "Товары из ассортиментного минимума по объекту."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        /* по текущему объекту */
        v-sel-obj-type =  p-curr-obj-type .
        v-sel-obj-code =  p-curr-obj-code .
          { gbl/uobjsone.i        ~
            parparentproc         ~
            v-cntxt-db-num        ~
            v-cntxt-userid        ~
            v-cntxt-host-code-obj ~
            v-cntxt-obj-type      ~
            v-cntxt-obj-code      ~
            v-user-select         ~
            v-sel-obj-type        ~
            v-sel-obj-code        ~
          }
          if not v-user-select then do:
            return error.
          end.

        assign
        dsp-rs = substitute("Ассортиментный минимум на объекте : &1&2 &4"
                           ,v-sel-obj-type
                           ,v-sel-obj-code
                           ,stat-line(rs-status))
        v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code) + {&delim-key}
        .
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

      end.
      when "client" then do:
        glog = yes.
        message "Все товары из всех документов (накладных) по контрагенту" skip
                "(по всем объектам за все время работы программы)."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run ref/cli-all.w ( parparentproc
                        , "b-sel"
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , output ref-list) .
        if ref-list = "" then do:
          v-ref-rec = ?.
          run UI-on in this-procedure.
          return error.
        end.
        v-ref-rec = integer (ref-list).
        find clients where recid (clients) = v-ref-rec no-lock.
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Контрагент : &1 &2", clients.obj-name, stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input '':U
                                            , input {&table_clients}
                                            , input buffer clients:handle
                                            ).
      end.
      when "consignee" then do:
        glog = yes.
        message "Товары, которых данный контрагент получил больше, чем вернул" skip
                "(по всем объектам за все время работы программы)."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run ref/cli-all.w ( parparentproc
                        , "b-sel"
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , ?
                        , output ref-list) .
        if ref-list = "" then do:
          v-ref-rec = ?.
          run UI-on in this-procedure.
          return error.
        end.
        v-ref-rec = integer (ref-list).
        find clients where recid (clients) = v-ref-rec no-lock.
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Консигнант : &1 &2", clients.obj-name, stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input '':U
                                            , input {&table_clients}
                                            , input buffer clients:handle
                                            ).
      end.
      when "object"
      or
      when "available"
      or
      when "neg-rest"
      or
      when "neg-part"
      or
      when "neg-part-free"
      or
      when "neg-prt"
      or
      when "nul-rest"
      or
      when "with-price"
      or
      when "ov-req"
      or
      when "inv-req"
      or
      when "input"
      or
      when "etalon"
      then do:
        run object-options in this-procedure (input rs-list-method).
      end.
      when "fbr-gds-obj" or when "fbr-gds-obj-val" then do:
        run trig-fbr in this-procedure (input rs-list-method) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "dis-gds-rule" or when "dis-gds-rule-num" then do:
        run trig-dis-gds-rule in this-procedure no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "gds-obj-attr" or when "gds-obj-attr-val" then do:
        run trig-attr in this-procedure ( input "gds-obj-attr", input {&gdsoattr-list}) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "gds-host-attr" or when "gds-host-attr-val" then do:
        run trig-attr in this-procedure ( input "gds-host-attr", input {&gdshattr-list} ) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "goods-attr" or when "goods-attr-val" then do:
        run trig-attr in this-procedure ( input "goods-attr" , input {&gds-attr-list}) no-error.
        if error-status:error then do:
          run Ui-on.
          return no-apply.
        end.
      end.
      when "tax-rate-value":U
      or
      when "tax-rate-value-obj":U
      then do:
        run trig-tax-rate-value(input rs-list-method, output v-date) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "scales-gds" or when "scales-gds-num" then do:
        run proc-scales-gds(rs-list-method) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "parts-last-date" then do:
        run proc-parts-last-date(rs-list-method) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "parts-last-date" then do:
        run proc-parts-fib(rs-list-method) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "cashparts" then do:
        glog = yes.
        message
        "Товары с продажей по партиям."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        /* по текущему объекту */
        v-sel-obj-type =  p-curr-obj-type .
        v-sel-obj-code =  p-curr-obj-code .
          { gbl/uobjsone.i        ~
            parparentproc         ~
            v-cntxt-db-num        ~
            v-cntxt-userid        ~
            v-cntxt-host-code-obj ~
            v-cntxt-obj-type      ~
            v-cntxt-obj-code      ~
            v-user-select         ~
            v-sel-obj-type        ~
            v-sel-obj-code        ~
          }
          if not v-user-select then do:
            return error.
          end.
        assign
        dsp-rs = substitute("Товары с продажей по партиям на объекте : &1&2 &4"
                           ,v-sel-obj-type
                           ,v-sel-obj-code
                           ,stat-line(rs-status))
        v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code)
        .
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
      end.
      when "is-ptrl"
      or when "gds-office"
      then do:
        run proc-simple(rs-list-method) no-error.
        if error-status:error then do:
          run Ui-on in this-procedure.
          return no-apply.
        end.
      end.
      when "doc-list" then do:
        glog = yes.
        message "Все товары по документам из ранее сохраненного в файле списка документов"
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        system-dialog get-file f-doc-name
          filters "Списки документов *.trn" "*.trn"
          title "Выберите файл списка"
          INITIAL-DIR "."
          return-to-start-dir
          must-exist
          /* use-filename */
          update glog
          default-extension "trn".
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Файл списка документов: &1 &2", f-doc-name, stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input f-doc-name
                                            , input '':U
                                            , input ?
                                            ).
      end.
      when "prod-list"
      or
      when "supp-list"
      or
      when "cli-list" then do:
        glog = yes.
        if rs-list-method = "prod-list" then do:
          assign
          v-message = substitute("Все товары производителей из ранее сохраненного в файле списка клиентов&1&2"
                                  , {&new-line}
                                  , stat-line(rs-status))
          dsp-rs = substitute("Файл списка производителей: &1", f-cli-name, stat-line(rs-status))
          .
        end.
        if rs-list-method = "supp-list" then do:
          assign
          v-message = substitute("Все товары поставщиков из ранее сохраненного в файле списка клиентов&1&2"
                                  , {&new-line}
                                  , stat-line(rs-status))
          dsp-rs = substitute("Файл списка поставщиков: &1 &2", f-cli-name, stat-line(rs-status))
          .
        end.
        if rs-list-method = "cli-list" then do:
          assign
          v-message = substitute("Все товары из всех документов (накладных) по контрагентам&1" +
                                "из ранее сохраненного в файле списка клиентов&1"  +
                                "(по всем объектам за все время работы программы&1&1"
                                  , {&new-line}
                                  , stat-line(rs-status))
          dsp-rs = substitute("Файл списка контрагентов: &1 &2", f-cli-name, stat-line(rs-status))
          .
        end.
        message
        v-message
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        system-dialog get-file f-cli-name
          filters "Списки клиентов *.cli" "*.cli"
          title "Выберите файл списка"
          INITIAL-DIR "."
          return-to-start-dir
          must-exist
          /* use-filename */
          update glog
          default-extension "cli".
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input dsp-rs
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input f-cli-name
                                            , input '':U
                                            , input ?
                                            ).
      end.
      when "deleted" then do:
        if RS-status = {&current} then do:
          message
          "Переключатель <СТАТУС> стоит в положениии <Текущие>" skip
          "Вы не cможете выбрать ни одного товара"
          view-as alert-box error .
          run UI-on in this-procedure.
          return error.
        end.
        glog = yes.
        message "Все неактивные товары."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("ВСЕ неактивные товары &1", stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input 'deleted':U
                                            , input '':U
                                            , input ?
                                            ).
      end.
      when "file" then do:
        glog = yes.
        message "Все товары из ранее сохраненного в файле списка"
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
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
          run UI-on in this-procedure.
          return error.
        end.
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Файл списка : &1 &2", f-name, stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input f-name
                                            , input '':U
                                            , input ?
                                            ).
      end.
      when "clob-data" then do:
        glog = yes.
        message "Все товары из ранее сохраненного в БД списка"
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        run ref/clobbnds.w ( input parparentproc
                            ,input this-procedure:handle
                            ,input 'b-sel' /*bttns*/
                            ,input "uniq-key-rec" /*p-list-mode*/
                            ,input "" /*p-mode*/
                            ,input {&lob-res-list}
                            ,input 'gds-list' /*p-unique-key-rec*/
                            ,input -1 /*p-db-num*/
                            ,input-output v-rid-list) no-error.
        if v-rid-list = '' then do:
          run UI-on in this-procedure.
          return error.
        end.
        find first buf_clob-bind no-lock where
                  recid(buf_clob-bind) = integer(v-rid-list) .
        run gen-key-rec in this-procedure ( input {&table_clob-bind}
                                           ,input (buffer buf_clob-bind:handle)
                                           ,output v-uniq-key-rec).
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name, stat-line(rs-status))
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-uniq-key-rec
                                            , input '':U
                                            , input ?
                                            ).
      end.
      when "scaner" then do:
        glog = yes.
        message "Все товары из файла, полученного с мобильного сканера."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        system-dialog get-file f-name
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
          run UI-on in this-procedure.
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
                                            , input f-name
                                            , input '':U
                                            , input ?
                                            ).
      end.
      when "filter" then do:
        glog = yes.
        message "Все товары, выбранные в соответствии с заданным фильтром (без учета сортировки)."
        skip stat-line(rs-status)
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run UI-on in this-procedure.
          return error.
        end.
        assign
        tbl = 'goods,clients'
        join-tbl = ','
        fld = ""
        lab = ""
        spr = ""
        dim = '0'
        c-point = "gds-list" + {&delim-par} + "Список товаров" + {&delim-par} + "no"
        .

        define variable v-flt-rec as recid no-undo .
        define variable v-filter-name as character no-undo .
        define variable where-phrase as character no-undo .
        define variable sort-phrase as character no-undo .
        define variable where-phrase-rus as character no-undo .
        define variable sort-phrase-rus as character no-undo .
        run fltfield-add in this-procedure('artic', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('gds-name', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('engl-name', 'Название по-английски', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('chk-name', 'Название на чеке', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('prod-type{&delim-flt}prod-code', 'Производитель', 'cli',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('unit-base', '', 'unit',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('unit-cli', '', 'unit',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('grp-name', '', 'gdsgrp',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('prt-root', 'Шкала', 'prt',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('increase-pc', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('calc-method', 'Метод наценки', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('qnty-cart', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('okdp', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('destin', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('sert', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('struct', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('sort', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('deadline', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('negative-rest', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('cost-calc', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('gds-type', 'Услуга-товар', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('tnved', 'Код ТНВЭД', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('nationality', '', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('unit-cst', 'Таможенная единица', 'unit',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('alpha1', 'Код страны изготовления', 'country',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('normal-wastage', 'Норма естест.убыли', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('normal-waste', 'Норма отходов', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('min-rate', 'Min кол-во в штуке', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('max-rate', 'Max кол-во в штуке', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('ms-base', 'Объем штуки', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('ms-cart', 'Объем упаковки', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('wt-base', 'Все штуки', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('wt-cart', 'Веc упаковки', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('cond-keep-code', 'Условия хранения', 'cond-keep',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

        assign
        fld = fld
        lab = lab
        dim = dim + {&comma-char}
        .

        run fltfield-add in this-procedure('obj-name', 'Название производителя', '',
        input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
        run fltfield-add in this-procedure('grp-name', 'Группа производителей', '',
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
      when "move-date" then do:
       define variable v-date-chr       as character           no-undo .
       define variable v-date       as date           no-undo .
    
        run gbl/d-prompt.w (
          'title=':u + "Введите дату начала периода движения товара" + '\':u
        + 'text1=':u + "Дата" + '\':u
        + 'format=' + "99/99/9999" + '\':u
        + 'type=' + {&type-date} + '\':u
        + 'fillin_row=2\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
        + 'readonly=no' + '\':u
        , input-output v-date-chr
        ).
        if return-value = 'false':u then return error.
        assign
        v-date = date( integer(substr(v-date-chr, 4, 2))
                      ,integer(substr(v-date-chr, 1, 2))
                      ,integer(substr(v-date-chr, 7, 4))
                     )
        no-error .
        if error-status:error then return error.
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-seq
                                            , input 0
                                            , input '':U
                                            , input substitute("Дата начала периода: &1", v-date)
                                            , input tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-date
                                            , input '':U
                                            , input ?
                                            ).
      end.
    end.
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
          run UI-on in this-procedure.
          return error.
        end.
      END CASE.
      if error-status:error then do:
        run UI-on in this-procedure.
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
    and not p-keep-query
    then do:
      run proc-b-add in this-procedure(no, ?, rs-list-method, rs-status)  .
    end.
  end.
end.

end procedure. /* proc-vc-rs-list-method */


PROCEDURE trig-attr :
define input parameter p-attr-table as character no-undo .
define input parameter p-list       as character no-undo .
/*p-attr-table может быть gds-obj-attr или gds-host-attr или goods-attr*/
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE vattr-codes          as character           no-undo.
DEFINE VARIABLE vattr-labels         as character           no-undo.
DEFINE VARIABLE vtooltip             as character           no-undo.
DEFINE VARIABLE vlabel               as character           no-undo .
DEFINE VARIABLE vtype                as character           no-undo .
DEFINE VARIABLE vformat              as character           no-undo .
DEFINE VARIABLE vuser-can-edit       as logical             no-undo .
DEFINE VARIABLE voutput-display      as logical             no-undo .
DEFINE VARIABLE vother               as character           no-undo .
DEFINE VARIABLE v-ref-list           as character           no-undo .
DEFINE VARIABLE jj                   as integer             no-undo .
DEFINE VARIABLE v-spr                as character           no-undo .
DEFINE VARIABLE v-spr-param          as character           no-undo .
DEFINE VARIABLE v-setted             as logical             no-undo .
define variable v-init               as character           no-undo .
define variable v-item               as character           no-undo .
define variable glog as logical no-undo .
define variable v-list               as character           no-undo .

assign
v-attr-code = ""
vattr-codes = ""
vattr-labels = ""
vvalue = ""
.

DO ii = 1 to num-entries ( p-list):
    CASE p-attr-table:
      when "gds-obj-attr" then do:
        run gdsoattr-name  in this-procedure (
                                              input entry(ii, p-list)
                                              ,output vtype
                                              ,output vformat
                                              ,output vlabel
                                              ,output vuser-can-edit
                                              ,output voutput-display
                                              ,output vother) no-error.
      end.
      when "gds-host-attr" then do:
        v-list = {&gdshattr-list}.
        run gdshattr-name in this-procedure (
                                              input entry(ii, p-list)
                                            ,output vtype
                                            ,output vformat
                                            ,output vlabel
                                            ,output vuser-can-edit
                                            ,output voutput-display
                                            ,output vother) no-error.

      end.
      WHEN "goods-attr" then do:
        run gds-attr-name in this-procedure (
                                              input entry(ii, p-list)
                                              ,output vtype
                                              ,output vformat
                                              ,output vlabel
                                              ,output vuser-can-edit
                                              ,output voutput-display
                                              ,output vother) no-error.

      end.
    END CASE.
    if NOT error-status:error anD VOUTPUT-DISPLAY = yes then do:
        assign
        vattr-codes = vattr-codes + {&delim-par} + entry(ii, p-list)
        vattr-labels = vattr-labels + {&delim-par} + vlabel
        .
    end.
end.
run gbl/d-list.w ( input "b-sel":U
                  ,input "Выберите атрибут"
                  ,input vattr-codes
                  ,input vattr-labels
                  ,input {&delim-par}
                  ,input "":U
                  ,output v-attr-code).
if v-attr-code = "" then do:
  return error.
end.
glog = yes.
CASE rs-list-method:
  when "gds-obj-attr":U then do:
    run gdsoattr-tooltip  in this-procedure( input v-attr-code,
                         output vtooltip,
                         output vlabel).
    message
    "Все товары с установленным атрибутом на объекте" vlabel skip
    stat-line(rs-status)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.

    { gbl/uobjsone.i        ~
      parparentproc         ~
      v-cntxt-db-num        ~
      v-cntxt-userid        ~
      v-cntxt-host-code-obj ~
      v-cntxt-obj-type      ~
      v-cntxt-obj-code      ~
      v-user-select         ~
      v-sel-obj-type        ~
      v-sel-obj-code        ~
    }
    if not v-user-select then do:
      return error.
    end.
    assign
    dsp-rs = substitute("ВСЕ товары с установленным атрибутом на объекте &1 &2", vlabel, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code) + {&delim-key} + v-attr-code
    .
  end.
  when "gds-obj-attr-val":U then do:
    run gdsoattr-name  in this-procedure (
                         input v-attr-code,
                         output vtype,
                         output vformat,
                         output vlabel,
                         output vuser-can-edit,
                         output voutput-display,
                         output vother).
    do jj = 1 to num-entries(vother, {&slash-char}):
      if entry(1, entry(jj, vother, {&slash-char}), "=":U) = "init":U then do:
        assign
        v-init = string(entry(2, entry(jj, vother, {&slash-char}), "=":U))
        .
      end.
    end. /*jj*/
    do jj = 1 to num-entries(vother, {&slash-char}):
      if entry(1, entry(jj, vother, {&slash-char}), "=":U) = "spr":U then do:
        assign
        v-spr = entry(2, entry(jj, vother, {&slash-char}), "=":U)
        .
      end.
      if entry(1, entry(jj, vother, {&slash-char}), "=":U) = "spr-param":U then do:
        assign
        v-spr-param = entry(2, entry(jj, vother, {&slash-char}), "=":U)
        .
      end.
    end.

    { gbl/uobjsone.i        ~
      parparentproc         ~
      v-cntxt-db-num        ~
      v-cntxt-userid        ~
      v-cntxt-host-code-obj ~
      v-cntxt-obj-type      ~
      v-cntxt-obj-code      ~
      v-user-select         ~
      v-sel-obj-type        ~
      v-sel-obj-code        ~
    }
    if not v-user-select then do:
      return error.
    end.
    if  v-init <> "":U then do:
        run  value(v-init)
                    in this-procedure (
                                         input 0
                                       , input v-sel-obj-type
                                       , input v-sel-obj-code
                                       , output vvalue) no-error .
          if error-status:error then do:
              assign
              vvalue = "":U
              .
          end.
    end.
    CASE vtype:
      when {&type-log} then do:
        assign
        vvalue = "yes":U
        .
      end.
      when {&type-int} or when {&type-dec} then do:
        assign
        vvalue = if v-init <> "":U
                      then vvalue
                      else string(0)
        .
      end.
      when {&type-date} then do:
        assign
        vvalue = ?
        .
      end.
      when {&type-char} then do:
        assign
        vvalue = if v-init <> "":U
                      then vvalue
                      else "":U
        .
      end.
    END CASE.
    if v-spr = "":U then do:
      run gbl/d-prompt.w (
        'title=':u + "Значение атрибута товара на объекте" + '\':u
      + 'text1=':u + vlabel + '\':u
      + 'format=' + (if vtype = {&type-log} then "yes/no" else vformat) + '\':u
      + 'type=' + vtype + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=20\':u
      + 'fillin_height=1\':u
      + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
      + 'readonly=no\':u
      , input-output vvalue
      ).
      if return-value = 'false':U then do:
        return error.
      end.
    end.
    else do:
      if v-spr-param = "":U then do:
        run  value(v-spr)
                      in this-procedure (
                                        input 0
                                        ,input v-sel-obj-type
                                        ,input v-sel-obj-code
                                        ,input-output vvalue
                                        ,output v-setted) no-error .
      end.
      else do:
        run  value(v-spr)
                      in this-procedure (
                                        input 0
                                        ,input v-sel-obj-type
                                        ,input v-sel-obj-code
                                        ,input v-spr-param
                                        ,input-output vvalue
                                        ,output v-setted) no-error .
      end.
      if not v-setted then do:
        return error.
      end.
    end.
    message
    ("Все товары с атрибутом товара на объекте" + {&space-char} + vlabel + " = ":U + vvalue) skip
    stat-line(rs-status)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs = substitute("ВСЕ товары с атрибутом товара на объекте &1 =&2 &3", vlabel, vvalue, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code) + {&delim-key} + v-attr-code + {&delim-key} + vvalue
    .
  end.
  when "gds-host-attr":U then do:
    run gdshattr-tooltip  in this-procedure
                         (input v-attr-code,
                         output vtooltip,
                         output vlabel).
    message "Все товары с установленным атрибутом на фирме" vlabel skip
    stat-line(rs-status)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    {&sel-host}
    assign
    dsp-rs  = substitute("ВСЕ товары с установленным атрибутом на фирме &1 &2", vlabel, stat-line(rs-status))
    v-item = string(v-host-code) + {&delim-key} + v-attr-code
    .
  end.
  when "gds-host-attr-val" then do:
    run gdshattr-name   in this-procedure
                       ( input v-attr-code,
                         output vtype,
                         output vformat,
                         output vlabel,
                         output vuser-can-edit,
                         output voutput-display,
                         output vother).
    run gbl/d-prompt.w (
      'title=':u + "Значение атрибута товара на фирме" + '\':u
    + 'text1=':u + vlabel + '\':u
    + 'format=' + (if vtype = {&type-log} then "yes/no" else vformat) + '\':u
    + 'type=' + vtype + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output vvalue
    ).
    if return-value = 'false':U then do:
      return error.
    end.
    message ("Все товары с атрибутом товара на фирме" + {&space-char} + vlabel + " = ":U + vvalue) skip
    stat-line(rs-status)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    {&sel-host}
    assign
    dsp-rs = substitute("ВСЕ товары с атрибутом товара на фирме &1 = &2 &3", vlabel, vvalue, stat-line(rs-status))
    v-item  = string(v-host-code) + {&delim-key} + v-attr-code + {&delim-key} + vvalue
    .
  end.
  when "goods-attr":U then do:
    run gds-attr-tooltip in this-procedure (
                                              input v-attr-code,
                                              output vtooltip,
                                              output vlabel).
    message "Все товары с установленным глобальным атрибутом" vlabel skip
    stat-line(rs-status)
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs  = substitute("ВСЕ товары с установленным глобальным атрибутом &1 &2", vlabel, stat-line(rs-status))
    v-item = v-attr-code
    .
  end.
  when "goods-attr-val" then do:
    run gds-attr-name(   input v-attr-code,
                         output vtype,
                         output vformat,
                         output vlabel,
                         output vuser-can-edit,
                         output voutput-display,
                         output vother).
    run gbl/d-prompt.w (
      'title=':u + "Значение глобального атрибута товара " + '\':u
    + 'text1=':u + vlabel + '\':u
    + 'format=' + (if vtype = {&type-log} then "yes/no" else vformat) + '\':u
    + 'type=' + vtype + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output vvalue
    ).
    if return-value = 'false':U then do:
      return error.
    end.
    message substitute("Все товары с глобальным атрибутом товара &1 = &2&3&4"
                        ,vlabel
                        ,vvalue
                        ,{&new-line}
                        ,stat-line(rs-status))
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs = substitute("ВСЕ товары с глобальным атрибутом товара &1 = &2 &3", vlabel, vvalue, stat-line(rs-status))
    v-item  = v-attr-code + {&delim-key} + vvalue
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

PROCEDURE trig-fbr :
define input parameter p-method as character no-undo .
DEFINE VARIABLE vattr-codes          as character           no-undo.
DEFINE VARIABLE vattr-labels         as character           no-undo.
DEFINE VARIABLE vlabel               as character           no-undo .
DEFINE VARIABLE v-ref-list           as character           no-undo .
DEFINE VARIABLE v-fbr-list           as character           no-undo .
define variable v-grp-recid          as recid               no-undo .
define variable v-grp-code like ub.fbr-gds-obj.fbr-grp-code no-undo.
define variable glog as logical no-undo .
define variable v-item               as character           no-undo .
define variable v-fbr-obj-type       like ub.fbr-gds-obj.obj-type no-undo .
define variable v-fbr-obj-code       like ub.fbr-gds-obj.obj-code no-undo .
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.



if p-method = "fbr-gds-obj-val" then do:
  assign
  v-attr-code = ""
  vattr-codes = "is-cd,is-menu,is-null-price,is-modificator,is-season,is-semi-finished,fbr-grp-code,fbr-obj-code"
  vattr-labels = "Отправлять на кассу РЕСТОРАНА,Является блюдом меню,Без цены,Модификатор блюда,Применять сезонный коэффициент," +
                "Является полуфабрикатом,Группа меню,Кухня"
  vvalue = ""
  .
  run gbl/d-list.w ( input "b-sel":U
                    ,input "Выберите атрибут"
                    ,input vattr-codes
                    ,input vattr-labels
                    ,input {&comma-char}
                    ,input "":U
                    ,output v-attr-code).

  if v-attr-code = "" then do:
    return error.
  end.
  assign
  vlabel =  entry(lookup(v-attr-code, vattr-codes) ,vattr-labels)
  glog = yes.
end.

  { gbl/uobjsone.i        ~
    parparentproc         ~
    v-cntxt-db-num        ~
    v-cntxt-userid        ~
    v-cntxt-host-code-obj ~
    v-cntxt-obj-type      ~
    v-cntxt-obj-code      ~
    v-user-select         ~
    v-sel-obj-type        ~
    v-sel-obj-code        ~
  }
  if not v-user-select then do:
    return error.
  end.
if p-method = "fbr-gds-obj-val" then do:
  CASE v-attr-code:
    when "fbr-grp-code" then do:
        run ref/fbrggrp.w (
                input ?
              ,input v-sel-obj-type
              ,input v-sel-obj-code
              ,input "{&Btn_Select}"
              ,input-output v-grp-recid
          ).
      if v-grp-recid = ? then return error.
      FIND FIRST buf_fbr-gds-grp no-lock where
              recid(buf_fbr-gds-grp) = v-grp-recid No-ERROR.
      if not avail buf_fbr-gds-grp then return error.
      assign
      vvalue = string(buf_fbr-gds-grp.node-code)
      vlabel = vlabel + " = ":U + buf_fbr-gds-grp.node-name
      .
    end.
    when "fbr-obj-code" then do:
      message
      "Выберите объект-КУХНЮ для товара объекта" v-sel-obj-type v-sel-obj-code
      view-as alert-box.

      { gbl/uobjsone.i
        parparentproc
        v-cntxt-db-num
        v-cntxt-userid
        v-cntxt-host-code-obj
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-user-select
        v-fbr-obj-type
        v-fbr-obj-code
      }
      assign
      vvalue = string(v-fbr-obj-code)
      .
    end.
    otherwise do:
      assign
      vvalue = "yes":U
      .
      run gbl/d-prompt.w (
        'title=':u + "Значение атрибута товара на объекте" + '\':u
      + 'text1=':u + vlabel + '\':u
      + 'format=yes/no' + '\':u
      + 'type=logical' + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=20\':u
      + 'fillin_height=1\':u
      + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
      + 'readonly=no\':u
      , input-output vvalue
      ).
      if return-value = 'false':U then do:
        return error.
      end.
    end.
  END CASE.
  assign
  dsp-rs = substitute("Товары объекта &1&2 с атрибутом РЕСТОРАН &3 =&4&5&5"
                       ,  v-sel-obj-type, v-sel-obj-code, vlabel, vvalue
                       , {&new-line}
                       , stat-line(rs-status)
                       )
  v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code) + {&delim-key} + v-attr-code + {&delim-key} + vvalue
  .
end.
else do:
  assign
  dsp-rs = substitute("Товары объекта &1&2, имеющие атрибут РЕСТОРАН&3&4"
                     ,  v-sel-obj-type
                      , v-sel-obj-code
                       , {&new-line}
                       , stat-line(rs-status)
                     )
   v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code) + {&delim-key}
   .
end.
  message
  dsp-rs skip
  view-as alert-box question buttons OK-Cancel update glog.

if not glog then do:
  return error.
end.
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


PROCEDURE proc-scales-gds :
define input parameter rs-list-method as character no-undo .
define variable v-ref-list as character no-undo .
define variable v-rid-list as character no-undo .
define variable glog as logical no-undo .
define variable v-message as character no-undo .
define variable v-item as character no-undo .
define buffer buf_scales for ub.scales.
glog = yes.
CASE rs-list-method:
  when "scales-gds":U then do:
    assign
    v-message = substitute("Все товары на весах на объекте&1&2", {&new-line}, stat-line(rs-status))
    .
  end.
  when "scales-gds-num":U then do:
    assign
    v-message = substitute("Товары на одних весах на объекте &1&2", {&new-line}, stat-line(rs-status))
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
if rs-list-method = "scales-gds-num" then do:
  run ref/scales.w ( input parparentproc
                    ,input v-sel-obj-type
                    ,input v-sel-obj-code
                    ,input "b-sel"
                    ,input 'db':U
                    ,output v-rid-list).
  if v-rid-list = '':U then do:
    return error.
  end.
  find first buf_scales no-lock where
            recid(buf_scales) = integer(v-rid-list).
end.
CASE rs-list-method:
  when "scales-gds":U then do:
    assign
    dsp-rs = substitute("ВСЕ товары на весах на объекте &1&2 &3", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code)
    .
  end.
  when "scales-gds-num":U then do:
    assign
    dsp-rs = substitute("Товары на весах &1 на объекте &2&3 &4", buf_scales.scales-num, v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code)  + {&delim-key} + string(buf_scales.scales-num)
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
glog = yes.
CASE rs-list-method:
  when "parts-last-date":U then do:
    assign
    v-message = substitute("Партии свободной зоны на &1&2 с истекающим сроком хранения", {&new-line}, stat-line(rs-status))
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
      'title=':u + substitute("Введите кол-во дней в течение которых истекает срок хранения") + '\':u
    + 'text1=':u + "Кол-во дней" + '\':u
    + 'format=' + ">>9" + '\':u
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
    dsp-rs = substitute("Партии свободной зоны на &1&2 со сроком хранения, истекающим через &3 дн.  и ранее &4", v-sel-obj-type, v-sel-obj-code, v-value-integer, stat-line(rs-status))
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
glog = yes.
CASE rs-list-method:
  when "parts-last-date":U then do:
    assign
    v-message = substitute("ФиБ партии свободной зоны на &1&2", {&new-line}, stat-line(rs-status))
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
    dsp-rs = substitute("ФиБ партии свободной зоны на &1&2 &4", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
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


PROCEDURE proc-simple :
define input parameter rs-list-method as character no-undo .
define variable v-ref-list as character no-undo .
define variable v-rid-list as character no-undo .
define variable glog as logical no-undo .
define variable v-message as character no-undo .
define variable v-item as character no-undo .
define buffer buf_scales for ub.scales.
glog = yes.
CASE rs-list-method:
  when "is-ptrl":U then do:
    assign
    v-message = substitute("Все топлива&1&2", {&new-line}, stat-line(rs-status))
    .
  end.
  when "gds-office":U then do:
    assign
    v-message = substitute("Все услуги&1&2", {&new-line}, stat-line(rs-status))
    .
  end.
END CASE.
message
v-message
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
CASE rs-list-method:
  when "is-ptrl":U then do:
    assign
    dsp-rs = substitute("ВСЕ топлива &1", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = '':U
    .
  end.
  when "gds-office":U then do:
    assign
    dsp-rs = substitute("ВСЕ услуги &1", v-sel-obj-type, v-sel-obj-code, stat-line(rs-status))
    v-item = '':U
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

PROCEDURE trig-dis-gds-rule :
define variable v-rid-list as character no-undo .
define variable v-pos-type as character no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable v-time-templ-rl-root as integer no-undo .
define variable v-cfg-nonunique as character no-undo .
define variable v-nonunique as character no-undo .
define variable v-discnt-role as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable r-b-code as integer no-undo .
define variable v-sts as integer no-undo .
define variable glog as logical no-undo .
define variable v-mode as character no-undo .
define variable v-item as character no-undo .
define variable v-rule-num as integer no-undo .
define variable dflt-cd as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-rule for ub.dis-rule.
/*выбеерем POS*/

if v-cntxt-obj-type = {&stock} then do:
  dflt-cd = {&cd-type-no-cd}.
end.
else do:
  { gbl/dflt-cd.i v-cntxt-obj-type v-cntxt-obj-code dflt-cd }
  assign
  v-pos-type = dflt-cd + {&comma-char} + {&cd-type-no-cd} + {&comma-char} + {&cd-type-bo}.

end.

run ref/dis-pos.w ( INPUT parparentproc
                    ,INPUT "b-sel":U
                    ,INPUT (if rs-list-method = "dis-gds-rule"
                           then "cd-type-list-without-template-pos"
                           else "cd-type-list")
                    ,INPUT 1
                    ,INPUT 1
                    ,INPUT 1
                    ,input {&table_dis-gds-rule}
                    ,input '':U
                    ,input ?
                    ,INPUT v-pos-type
                    ,input '':U
                    ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR
OR v-rid-list = '':U THEN DO:
  RETURN.
END.
FIND FIRST buf_dis-cfg-rule NO-LOCK where
          recid(buf_dis-cfg-rule) = INTEGER(v-rid-list).
assign
v-templ-rl-root = buf_dis-cfg-rule.templ-rl-root
v-time-templ-rl-root = buf_dis-cfg-rule.time-templ-rl-root
V-cfg-NONUNIQUE = buf_dis-cfg-rule.nonunique
v-discnt-role = buf_dis-cfg-rule.discnt-role
.

&scop dis-gds-rule-code buf_dis-cfg-rule.discnt-role
if rs-list-method = "dis-gds-rule" then do:
  message
  "Все товары со скидкой типа" {&dis-gds-rule-name} skip
  stat-line(rs-status)
  view-as alert-box question buttons OK-Cancel update glog.
end.
else do:
  message
  "Все товары со скидкой типа" {&dis-gds-rule-name} "и определенным номером правила скидки" skip
  stat-line(rs-status)
  view-as alert-box question buttons OK-Cancel update glog.

end.
if not glog then do:
  return error.
end.
if (buf_dis-cfg-rule.has-global +
    buf_dis-cfg-rule.has-host +
    buf_dis-cfg-rule.has-obj) > 1 then do:
  /*надо выбрать todo*/
  define variable v-sel-vals as character no-undo .
  define variable v-sel-labels as character no-undo .
  define variable var-region as character no-undo .
  assign
  v-sel-vals = v-sel-vals +
                (if buf_dis-cfg-rule.has-global = 1
                then (fill({&space-char}, 3)  + string(0) + {&delim-par} )
                else "":U)
  v-sel-labels = v-sel-labels +
                (if buf_dis-cfg-rule.has-global  = 1
                then ("Глобально" + {&delim-par} )
                else "":U)
  .
  assign
  v-sel-vals = v-sel-vals +
                (if buf_dis-cfg-rule.has-host = 1
                then ({&cmp}  + string(v-cntxt-host-code-obj)  + {&delim-par} )
                else "":U)
  v-sel-labels = v-sel-labels +
                (if buf_dis-cfg-rule.has-host = 1
                then ("Фирма"  + string(v-cntxt-host-code-obj) + {&delim-par} )
                else "":U)
  .
  assign
  v-sel-vals = v-sel-vals +
                (if buf_dis-cfg-rule.has-obj = 1
                then (v-cntxt-obj-type  + string(v-cntxt-obj-code)  + {&delim-par} )
                else "":U)
  v-sel-labels = v-sel-labels +
                (if buf_dis-cfg-rule.has-obj = 1
                then (v-cntxt-obj-type  + string(v-cntxt-obj-code)  + {&delim-par} )
                else "":U)
  .
  run gbl/d-list.w (
                      input "b-sel":U
                      ,input "Выберите область действия"
                      ,input v-sel-vals
                      ,input v-sel-labels
                      ,input {&delim-par}
                      ,input "":U
                      ,output var-region) no-error.
  if error-status:error then do:
    return error.
  end.
  assign
  v-obj-type = substring(var-region, 1, 3)
  v-obj-code = integer(substring(var-region, 4))
  v-sel-obj-type = v-obj-type
  v-sel-obj-code = v-obj-code
  .
end.
else do:
  if buf_dis-cfg-rule.has-obj = 1 then do:
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

    assign
    v-obj-type = v-sel-obj-type
    v-obj-code = v-sel-obj-code
    .
  end.
  if buf_dis-cfg-rule.has-host = 1 then do:
    define variable v-host-code as integer no-undo .
    assign
    v-obj-type = {&cmp}
    v-obj-code = v-cntxt-host-code-obj
    .
  end.
  if buf_dis-cfg-rule.has-glob = 1 then do:
    assign
    v-obj-type = '':U
    v-obj-code = 0
    .
  end.
end.

if rs-list-method = "dis-gds-rule" then do:
  assign
  dsp-rs = substitute("ВСЕ товары с установленным типом скидки &1 &2"
                    , get-objregion(v-obj-type, v-obj-code), stat-line(rs-status))
  v-item = v-sel-obj-type + {&delim-key} + string(v-sel-obj-code) + {&delim-key} + v-discnt-role   .
end.
else do:
  /*выберем правило*/
  v-mode = (if v-obj-type = {&shop}
            or v-obj-type = {&stock}
            then "upper-rule-num-object":u
            else ({&table_dis-gds-rule} + "=" + v-discnt-role)).
  run ref/dis-ruls.w (
               input parparentproc
              ,input 0 /*p-host-code*/
              ,input v-obj-type
              ,input v-obj-code
              ,input "b-add,b-sel":U
              ,input v-mode
              ,input v-templ-rl-root
              ,input v-time-templ-rl-root
              ,input r-b-code
              ,input-output v-sts
              ,input-output v-rid-list ) no-error .
  if v-rid-list = '':u then do:
    return error.
  end.
  find first buf_dis-rule no-lock where
           recid(buf_dis-rule) = integer(v-rid-list) no-error.
  if available buf_dis-rule then do:
  assign
  dsp-rs = substitute("ВСЕ товары с установленным типом скидки: &1, № правила &2 &3"
                      ,get-objregion(v-obj-type, v-obj-code)
                      ,v-rule-num
                      ,stat-line(rs-status))
  v-item = v-sel-obj-type + {&delim-key} +
            string(v-sel-obj-code) + {&delim-key} +
              v-discnt-role + {&delim-key} + string(buf_dis-rule.rule-num)
  .
end.
  else do:
    message
    substitute("Не найдено провило скидки с recid &1", v-rid-list)
    view-as alert-box error .
    return error.
  end.
end.
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


procedure proc-scn-tsd :
define variable glog as logical no-undo .
define buffer buf_{1}-hist for {1}-hist.

  do
  on error undo, return error
  :
&if "{1}" = "scn-list" &then
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
  output stream PrnLibStream to value (f-name).
  for each {1},
      each ub.gds-prt where ub.gds-prt.upper-code = {1}.prt-root no-lock,
      each ub.bar-code where ub.bar-code.gds-code = {1}.gds-code
                      and ub.bar-code.unit-cli = {1}.unit-base
                      and ub.bar-code.node-code = ub.gds-prt.node-code
                      and ub.bar-code.in-code = ""
                      and ub.bar-code.part-code = "" no-lock:
    if {1}.qnty <> 0 then
      put stream PrnLibStream unformatted string (ub.bar-code.b-code) + "," + string ({1}.qnty) skip.
  end.
  output stream PrnLibStream close.
  run waitfram-hide in this-procedure .
&else
  run str/diallog.w (parparentproc
              , this-procedure
              , 'str/rsendtsd.p':U
              , (p-curr-obj-type + {&delim-par} + string(p-curr-obj-code))
              , no /*p-auto-go*/
              , '':U
              , 'Пересылка товаров на ТСД') no-error .

&endif
  end.
end procedure. /* proc-scn-tsd */


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
    f-name = "default.gdm"
    glog = yes
    .
  system-dialog get-file f-name
    filters "Макрос создания списка товара *.gdm" "*.gdm"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "gdm".
  if not glog then do:
    apply "entry" to br-list in frame {&frame-name}.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Сохранение макроса формирования списка товара.    ЖДИТЕ...").
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
end procedure. /* proc-scn-tsd */


PROCEDURE trig-tax-rate-value :
define input parameter p-rs-list-method as character no-undo .
define output parameter p-date as date no-undo .
DEFINE VARIABLE v-codes          as character           no-undo.
DEFINE VARIABLE v-labels         as character           no-undo.
DEFINE VARIABLE v-type           as character           no-undo.
DEFINE VARIABLE v-format         as character           no-undo.
DEFINE VARIABLE v-values         as character           no-undo.
DEFINE VARIABLE v-code-output    as character           no-undo.
DEFINE VARIABLE v-value-output   as character           no-undo.
define variable vlabel           as character           no-undo .
define variable v-date-chr       as character           no-undo .
DEFINE VARIABLE v-time           as integer             no-undo .
DEFINE VARIABLE v-ref-list           as character           no-undo .
DEFINE VARIABLE jj                   as integer             no-undo .
define variable glog as logical no-undo .

assign
v-attr-code = ""
vvalue = ""
v-codes = {&vat-tax-code} + {&delim-par} + {&slt-tax-code}
v-labels = "НДС" + {&delim-par} +  "НП"
v-values = "0" + {&delim-par} + "0"
v-format = ">9.99":U + {&delim-par} + ">9.99":U
v-type = {&type-dec} + {&delim-par} + {&type-dec}
.
run gbl/d-listv.w (
               "b-mark,b-sel":U
              ,"Выберите налоги"
              , v-codes
              , v-labels
              , v-values
              , v-format
              , v-type
              , {&delim-par}
              , "":U
              , output v-attr-code
              , output vvalue
              ).
if v-attr-code = "" then do:
  return error.
end.
do jj = 1 to num-entries(v-attr-code, {&delim-par}):
  assign
  vlabel = vlabel + entry(LOOKUP(entry(jj, v-attr-code, {&delim-par}), v-codes, {&delim-par}), v-labels, {&delim-par}) + "=":U + entry(jj, vvalue, {&delim-par}) + {&new-line}
  .
end.
run cur-time in this-procedure(output p-date, output v-time).
assign
v-date-chr = string(p-date, "99/99/9999":U)
.
run gbl/d-prompt.w (
  'title=':u + "Введите дату значения налогов" + '\':u
+ 'text1=':u + "Дата" + '\':u
+ 'format=' + "99/99/9999" + '\':u
+ 'type=' + {&type-date} + '\':u
+ 'fillin_row=2\':u
+ 'fillin_col=4\':u
+ 'fillin_width=20\':u
+ 'fillin_height=1\':u
+ 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
+ 'readonly=no' + '\':u
, input-output v-date-chr
).
if return-value = 'false':u then return error.
assign
p-date = date( integer(substr(v-date-chr, 4, 2))
              ,integer(substr(v-date-chr, 1, 2))
              ,integer(substr(v-date-chr, 7, 4))
             )
no-error .
if error-status:error then return error.
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

glog = yes.
if p-rs-list-method = "tax-rate-value":U then do:
  message
  "Все товары с заданными значениями налогов на объекте на дату" v-date-chr skip
  vlabel skip
  stat-line(rs-status)
  view-as alert-box question buttons OK-Cancel update glog.
end.
if p-rs-list-method = "tax-rate-value-obj":U then do:
  message
  "Товары объекта с заданными значениями налогов на объекте на дату" v-date-chr skip
  vlabel skip
  stat-line(rs-status)
  view-as alert-box question buttons OK-Cancel update glog.
end.
if not glog then do:
  return error.
end.
if p-rs-list-method = "tax-rate-value":U then do:
  dsp-rs = substitute("ВСЕ товары с заданными значениями налогов на объекте &1 на дату &2 &3", vlabel, p-date, stat-line(rs-status)).
end.
if p-rs-list-method = "tax-rate-value-obj":U then do:
  dsp-rs = substitute("Товары объекта &1 с заданными значениями налогов на объекте &2 на дату &3 &4", vlabel, vlabel, p-date, stat-line(rs-status)).
end.
run create-{1}-hist in this-procedure(input {&add-def}
                                    , input-output v-seq
                                    , input 0
                                    , input '':U
                                    , input dsp-rs
                                    , input tot-lns
                                    , input rs-list-method
                                    , input rs-status
                                    , input v-sel-obj-type + {&delim-key} + string(v-sel-obj-code) + {&delim-key} +
                                            string(p-date, "99/99/9999") + {&delim-key} + v-attr-code + {&delim-key} + vvalue
                                    , input '':U
                                    , input ?
                                    ).
END PROCEDURE. /*trig-tax-rate-value*/

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
      find ub.goods where rowid(ub.goods) = p-rowid no-lock no-error .
    end.
    else do:
      run ref/gds-ref.p ( parparentproc
                      ,"b-sel,b-add"
                      ,?               /*p-stat */
                      ,?               /*p-list  */
                      ,?               /*p-cond  */
                      ,?               /*p-rec   */
                      ,?               /*p-grp   */
                      ,?               /*p-cli-type */
                      ,?               /*p-cli-code  */
                      ,p-curr-obj-type      /*p-obj-type  */
                      ,p-curr-obj-code       /*p-obj-code  */
                      ,?               /*p-other     */
                      , output ref-list).
      apply "entry" to br-list in frame {&frame-name}.
      if ref-list = "" then
        return no-apply.
      /* выбран товар */
      find ub.goods where recid (ub.goods) = integer (ref-list) no-lock.
    end.
    if available goods then do:
      run ex-gds  in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
      tot-lns = tot-lns + 1.
      run write-hist in this-procedure ( p-from-macro, rs-list-method, rs-status, line-mode).
    end.
    else do:
      return error "Нет в БД такого товара".
    end.
    run UI-on  in this-procedure.
  end.
  else
    run rs-do  in this-procedure( no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
  end.

end procedure. /* proc-b-add */


procedure proc-b-del :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define variable v-rep-rec as recid no-undo .


define variable glog as logical no-undo .
  do
  on error undo, return error
  :
    line-mode = {&deletion}.
    if rs-list-method = "single" then do:
      v-no-hist = - 1.
      if p-from-macro then do:
        find first ub.goods where rowid(ub.goods) = p-rowid no-error.
        if not available ub.goods then return error "Нет в БД такого товара".
        find first {1} where {1}.gds-code = ub.goods.gds-code no-error.
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
        run write-hist in this-procedure ( p-from-macro, rs-list-method, rs-status, line-mode).
        delete {1}.
        line-rec = v-rep-rec.
        run UI-on in this-procedure.
      end.
      else do:
        return error "Нет в списке товаров такого товара".
      end.
    end.
    else do:
      glog = no.
      message "Удалить товары ПО заданному УСЛОВИЮ ?   Вы уверены ?"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then
        return no-apply.
      run rs-do  in this-procedure( no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
    end.
  end. /*doe*/

end procedure. /* proc-b-del */

procedure proc-b-rest :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define buffer buf_{1}-hist for {1}-hist.

define variable glog as logical no-undo .
  do
  on error undo, return error
  :
    line-mode = {&leave}.
    if rs-list-method = "single" then do:
      v-no-hist = - 1.
      if p-from-macro then do:
        find first ub.goods where rowid(ub.goods) = p-rowid no-error.
        if not available ub.goods then return error substitute("Нет в БД такого товара").
        find first {1} where {1}.gds-code = ub.goods.gds-code no-error.
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
        run write-hist  in this-procedure ( p-from-macro, rs-list-method, rs-status, line-mode).
        for each {1}:
          if line-rec <> recid ({1}) then delete {1}.
        end.
        assign
        tot-lns = 1
        .
        run UI-on  in this-procedure.
      end.
      else do:
        return error substitute("Нет в списке такого товара").
      end.
    end.
    else do:
      glog = no.
      if not p-from-macro then do:
        message "Оставить товары ПО заданному УСЛОВИЮ и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then
          return no-apply.
      end.
      assign
      lns-cnt = 0
      lns-ignore = 0
      .
      run rs-do  in this-procedure ( no, no, rs-list-method, rs-status, line-mode, v-seq - 1).
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
      run UI-on  in this-procedure.
      message
      "Оставлено строк :" lns-cnt skip(0)
      string(if lns-ignore <> 0
      then ("Проигнорировано строк :" + string(lns-ignore))
      else "":U)
      .
    end.
  end. /*doe*/

end procedure. /* proc-b-rest */

procedure proc-b-obj :
  define input parameter p-mode as character no-undo .

  define buffer buf_clients  for ub.clients.
  do
  on error undo, return error
  :
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
    end.
    if v-user-select then do:
      find first buf_clients no-lock where
                 buf_clients.obj-type = v-sel-obj-type
             and buf_clients.obj-code = v-sel-obj-code no-error.
      if not available buf_clients then do: return error. end.
      assign
        p-curr-obj-type = buf_clients.obj-type
        p-curr-obj-code = buf_clients.obj-code
        p-curr-host-code = buf_clients.host-code
        v-obj-type = buf_clients.obj-type
        v-obj-code = buf_clients.obj-code
        v-obj-name = buf_clients.obj-name
      .
      if lookup(bttns, "hide") = 0 then do:
        display
        v-obj-name
        v-obj-type
        v-obj-code
        with frame {&frame-name}.
      end.
    end.
  end.

end procedure. /* proc-b-obj */

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
define variable v-num-add          as integer no-undo .
define variable v-num-ignored      as integer no-undo .
define variable v-tbl-row          as rowid no-undo .
define variable v-tbl-name         as character no-undo .

define buffer buf_{1}-hist for {1}-hist.
define buffer buf_clob-data for ub.clob-data.
define buffer buf_clob-bind for ub.clob-bind.

do
on error undo, return error
:
find first buf_{1}-hist where
          buf_{1}-hist.id = p-id
      AND buf_{1}-hist.item_ <> '':U .
if rs-list-method = "clob-data" then do:
  run gen-row-keyr in this-procedure (
   input  buf_{1}-hist.item_    /*p-uniq-key-rec*/
  ,input  ? /*p-key-handle  буфер записи которую будем искать. если ищем по key-rec то ? */
  ,input  "ub"
  ,input  ? /*p-tt-handle   буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
  ,input NO-LOCK
  ,output v-tbl-row
  ,output v-tbl-name  ) no-error.
  if error-status :error then do:
    message
    "Ошибка при поиске хранимого файла"
    view-as alert-box error.
    return error.
  end.
  find first buf_clob-bind no-lock where
            rowid(buf_clob-bind) = v-tbl-row .
  find first buf_clob-data no-lock where
            buf_clob-data.db-num = buf_clob-bind.db-num
        and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
  if error-status :error then do:
    message
    "Ошибка при пополучении хранимого файла"
    view-as alert-box error.
    return error.
  end.
  run gbl/_tmpfile.p ( input ""
                ,input "tmp"
                ,output v-file-name) .
  copy-lob from object buf_clob-data.cdata
  to file v-file-name.
end.

run gbl/filename.p
    (input  (if rs-list-method = "clob-data" then v-file-name else buf_{1}-hist.item_  )/* p-search-file-name */
  ,output v-full-path         /* p-full-path        */
  ,output v-path              /* p-path             */
  ,output v-file-name         /* p-file-name        */
  ,output v-file-name-no-ext  /* p-file-name-no-ext */
  ,output v-file-name-ext     /* p-file-name-ext    */
  ) no-error .
  if error-status:error then do: end. else do:
  input stream sout from value (v-full-path).


  CASE rs-list-method:
    when "doc-list" then do:
      &if "{1}" = "scn-list" &then
      message "При чтении количеств из строк документов они в списке будут переписаны.".
      &endif
      repeat:
        import stream sout imp-doc-code imp-doc-type no-error.
        if imp-doc-type = {&overvalue} then do:
          find first ub.price-doc No-LOCK WHERE
                    ub.price-doc.doc-num = imp-doc-code No-ERROR.
          if avail(ub.price-doc) then do:
            FOR EACH ub.price-list No-LOCK WHERE
                    ub.price-list.doc-num = ub.price-doc.doc-num,
                FIRST ub.goods No-LOCK WHERE
                      ub.goods.artic = ub.price-list.artic AND
                      ub.goods.prod-type = ub.price-list.prod-type AND
                      ub.goods.prod-code = ub.price-list.prod-code:
              run ex-gds  in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
            /* количество пишем, если есть запись (не удаление и не попытка добавить удаленный товар),
              если это не запись, оставшаяся от предыдущего цикла */
              if available {1} and
                {1}.artic = ub.goods.artic and
                {1}.prod-type = ub.goods.prod-type and
                {1}.prod-code = ub.goods.prod-code then
                {1}.qnty = scan-qnty.
            END. /*for each ub.price-list*/
          end. /*if avail price-doc*/
        end. /*overturn*/
        else do:
          find first ub.trn-doc NO-LOCK where
                    ub.trn-doc.doc-code = imp-doc-code No-ERROR.
          if avail(ub.trn-doc) then do:
            FOR EACH ub.doc-line NO-LOCK where
                    ub.doc-line.doc-code = ub.trn-doc.doc-code,
                FIRST ub.goods where ub.goods.artic = ub.doc-line.artic
                            and ub.goods.prod-type = ub.doc-line.prod-type
                            and ub.goods.prod-code = ub.doc-line.prod-code NO-LOCK:
              run ex-gds  in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
            /* количество пишем, если есть запись (не удаление и не попытка добавить удаленный товар),
              если это не запись, оставшаяся от предыдущего цикла */
              if available {1} and
                {1}.artic = ub.goods.artic and
                {1}.prod-type = ub.goods.prod-type and
                {1}.prod-code = ub.goods.prod-code then
                {1}.qnty = scan-qnty.
            end. /*for each doc-line*/
          end. /*if avail trn-doc*/
        end. /*not overturn*/
      end. /*repeat*/
    end. /*when "doc-list" then do:*/
    when "prod-list" then do:
      repeat:
        import stream sout imp-type imp-code no-error.
        for each ub.goods where ub.goods.prod-type = imp-type
                    and ub.goods.prod-code = imp-code no-lock:
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
    end.
    when "supp-list" then do:
      repeat:
        import stream sout imp-type imp-code no-error.
        for each ub.cli-gds where ub.cli-gds.cli-type = imp-type
                            and ub.cli-gds.cli-code = imp-code
                            and ub.cli-gds.host-code = p-curr-host-code no-lock,
              first ub.goods where ub.goods.artic = ub.cli-gds.artic
                          and ub.goods.prod-type = ub.cli-gds.prod-type
                          and ub.goods.prod-code = ub.cli-gds.prod-code no-lock:
          run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        end.
      end.
    end. /*when "prod-list" then do:*/
    when "cli-list" then do:
      input stream sout from value (f-cli-name).
      repeat:
        import stream sout imp-type imp-code no-error.
        for each ub.trn-doc where ub.trn-doc.cli-type = imp-type
                          and ub.trn-doc.cli-code = imp-code no-lock:
          for each ub.doc-line where ub.doc-line.doc-code = ub.trn-doc.doc-code no-lock,
              first ub.goods where ub.goods.artic = ub.doc-line.artic
                            and ub.goods.prod-type = ub.doc-line.prod-type
                            and ub.goods.prod-code = ub.doc-line.prod-code no-lock:
            run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
          end.
        end.
      end.
    end. /*when "cli-list" then do:*/
    when "file"
    or when "clob-data"
    then do:
      &if "{1}" = "scn-list" &then
      message "При чтении из файла количеств они в списке будут переписаны.".
      &endif
      repeat:
        import stream sout imp-type imp-code imp-art scan-qnty no-error.
        find ub.goods where ub.goods.prod-type = imp-type
                    and ub.goods.prod-code = imp-code
                    and ub.goods.artic     = imp-art no-lock no-error.
        if available ub.goods then run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        /* количество пишем, если есть запись (не удаление и не попытка добавить удаленный товар),
          если это не запись, оставшаяся от предыдущего цикла */
        if available ub.goods and  available {1} and
          {1}.artic = ub.goods.artic and
          {1}.prod-type = ub.goods.prod-type and
          {1}.prod-code = ub.goods.prod-code then
          {1}.qnty = scan-qnty.
      end.
      if rs-list-method = "clob-data" then do:
        os-delete value(v-full-path) .
      end.
    end. /*when "file" then do:*/
    when "scaner" then do:
      &if "{1}" = "scn-list" &then
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
          p-curr-obj-code
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
        find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK.
        run ex-gds in this-procedure ( buffer ub.goods, input rs-list-method, input rs-status, input line-mode).
        /* количество пишем, если есть запись (не удаление и не попытка добавить удаленный товар),
          если это не запись, оставшаяся от предыдущего цикла */
        if available {1} and
          {1}.artic = ub.goods.artic and
          {1}.prod-type = ub.goods.prod-type and
          {1}.prod-code = ub.goods.prod-code then
          {1}.qnty = {1}.qnty + scan-qnty * bc-qnty.               /* умножаем на коэффициент (вес) из бар-кода */
      end.
    end. /*when "scaner" then do:*/
  END CASE.
  input stream sout close.
  {&assign-nums}.
  end.
end.

end procedure. /* proc-file-list-methods */

procedure analysis:
define input  parameter p-method as character no-undo .
define variable glog as logical   no-undo .
define variable v-run as character no-undo .
define variable an-option as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-recs as integer   no-undo .
define variable v-temp-seq as integer   no-undo .
define variable v-line as integer   no-undo .
define variable v-item as character no-undo .
define variable v-tot-lns as integer   no-undo .
do
on error undo, return error return-value
:
  glog = yes.
  CASE p-method:
    when "abcxyz":U then do:
      assign
      dsp-rs = substitute("Товары ABC/XYZ анализа.&1&2",  stat-line(rs-status))
      v-run = 'ref/abcxyzv.w':U
      an-option = "abcxyz"
      v-tbl-name = {&table_abcxyz-analysis}
      v-bh       = buffer ub.abcxyz-analysis:handle
      .
    end.
    when "abc-analysis":U then do:
      assign
      dsp-rs = substitute("Товары ABC анализа.&1&2",  stat-line(rs-status))
      v-run = 'ref/abcanal.w':U
      an-option = "abc"
      v-tbl-name = {&table_abc-analysis}
      v-bh       = buffer ub.abc-analysis:Handle
      .
    end.

    when "xyz-analysis":U then do:
      assign
      dsp-rs = substitute("Товары XYZ анализа.&1&2",  stat-line(rs-status))
      v-run = 'ref/xyzanal.w':U
      an-option = "xyz"
      v-tbl-name = {&table_xyz-analysis}
      v-bh       = buffer ub.xyz-analysis:Handle
      .
    end.
  END CASE.
  message
  dsp-rs
  view-as alert-box question buttons OK-Cancel update glog.
  if not glog then do:
    run UI-on  in this-procedure.
    return error.
  end.
  run value(v-run)(parparentproc,"b-sel":U, output ref-list).
  if ref-list <> "" then run ref/togabc.w (input an-option, output list-abcxyz).
  if ref-list = "" or list-abcxyz = "" then do:
    run UI-on in this-procedure.
    return error.
  end.
  /* выбран анализ */
  if num-entries(ref-list) = 1 then do:
    CASE rs-list-method:
      when "abcxyz":U then do:
        find abcxyz-analysis where recid (abcxyz-analysis) = integer(entry(1, ref-list)) no-lock.
        dsp-rs = substitute("ABCXYZ Анализ : &1&2&3"
                            ,abcxyz-analysis.abcx-name
                            , {&new-line}
                            , stat-line(rs-status)
                            ).

      end.
      when "abc-analysis":U then do:
        find abc-analysis where recid (abc-analysis) = integer(entry(1, ref-list)) no-lock.
        dsp-rs = substitute("ABC Анализ : &1&2&3"
                            ,abc-analysis.abc-name
                            , {&new-line}
                            , stat-line(rs-status)
                            ).

      end.
      when "xyz-analysis":U then do:
        find xyz-analysis where recid (xyz-analysis) = integer(entry(1, ref-list)) no-lock.
        dsp-rs = substitute("XYZ Анализ : &1&2&3"
                            ,xyz-analysis.xyz-name
                            ,{&new-line}
                            ,stat-line(rs-status)
                            ).
      end.
    end CASE.
    /* выбран анализ и группы */
    v-recs = num-entries(list-abcxyz).
    do num-rec = 0 to v-recs:
      if num-rec = 0 then do:
        assign
        v-temp-seq = v-seq
        v-line     = 0
        v-item     = '':U
        v-tot-lns = tot-lns
        .
      end.
      else do:
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("Группа &1", entry(num-rec, list-abcxyz))
        v-item     = entry(num-rec, list-abcxyz)
        v-tbl-name = '':U
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
      end.
      v-no-hist = (if num-rec = 1 then 0 else num-rec).
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      if num-rec = 0 then v-seq  = v-temp-seq.
    end. /*do num-rec*/
  end.
end. /*doe*/

end procedure. /* analysis */

procedure collection :
define input  parameter p-method as character no-undo .
define variable glog as logical   no-undo .
define variable v-run as character no-undo .
define variable an-option as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-recs as integer   no-undo .
define variable v-temp-seq as integer   no-undo .
define variable v-line as integer   no-undo .
define variable v-item as character no-undo .
define variable v-tot-lns as integer   no-undo .
do
on error undo, return error return-value
:
  glog = yes.
  CASE p-method:
    when "collection":U then do:
      assign
      dsp-rs = substitute("Товары по коллекции.&1&2",  stat-line(rs-status))
      v-run = 'ref/collec.w':U
      an-option = "sea"
      v-tbl-name = 'season'
      v-bh       = buffer ub.season:Handle
      .
    end.
  END CASE.
  message
  dsp-rs
  view-as alert-box question buttons OK-Cancel update glog.
  if not glog then do:
    run UI-on.
    return error.
  end.
  run value(v-run) (parParentProc, "b-sel":U, output ref-list).
  if ref-list = "" then do:
    run UI-on.
    return error.
  end.
  /* выбрана коллекция */
  if num-entries(ref-list) = 1 then do:
    CASE rs-list-method:
      when "collection":U then do:
        find ub.season where recid (ub.season) = integer(entry(1, ref-list)) no-lock.
        dsp-rs = substitute("Коллекция : &1&2&3"
                            ,ub.season.sea-name
                            , {&new-line}
                            , stat-line(rs-status)
                            ).

      end.
    end CASE.
    /* выбран анализ и группы */
    v-recs = num-entries(ref-list).
    do num-rec = 0 to v-recs:
      if num-rec = 0 then do:
        assign
        v-temp-seq = v-seq
        v-line     = 0
        v-item     = '':U
        v-tot-lns = tot-lns
        .
      end.
      else do:
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        v-item     = entry(num-rec, ref-list)
        v-tbl-name = '':U
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
      end.
      v-no-hist = (if num-rec = 1 then 0 else num-rec).
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      if num-rec = 0 then v-seq  = v-temp-seq.
    end. /*do num-rec*/
  end.
end. /*doe*/
end procedure. /* collection */


procedure object-options :
define input  parameter p-method as character no-undo .
define variable glog as logical   no-undo .
define variable v-message as character no-undo .
define buffer buf_{1}-hist for {1}-hist.
define buffer buf_user-obj for ub.user-obj.

do
on error undo, return error return-value
:
  glog = yes.
  case p-method:
    when "object" then do:
      assign
      v-message = substitute("Все товары из справочника товаров по объекту.&1&2"
                              , {&new-line}
                              , stat-line(rs-status))
      dsp-rs    = "Все товары по объекту : &1 &2"
      .
    end.
    when "available"  then do:
        assign
        v-message = substitute("Все товары, остаток которых на объекте > 0.&1&2"
                              , {&new-line}
                              , stat-line(rs-status))
        dsp-rs =   "ВСЕ товары, имеющиеся в наличии на/в &1 &2"
        .
    end.
    when "neg-rest" then do:
        assign
        v-message = substitute("Все товары с отрицательными остатками на объекте.&1&2"
                              , {&new-line}
                              , stat-line(rs-status))
        dsp-rs     = "ВСЕ товары с отрицательными остатками на/в &1 &2"
        .
    end.
    when "neg-part" then do:
        assign
        v-message = substitute("Все товары, имеющие отрицательные партии на объекте (остаток при этом может быть любым).&1&2"
                              , {&new-line}
                              , stat-line(rs-status))
        dsp-rs    = "ВСЕ товары с отрицательными партиями на/в &1 &2"
        .
    end.
    when "neg-part-free" then do:
        assign
        v-message = substitute("Все товары, имеющие отрицательные партии в свободной зоне на объекте (остаток при этом может быть любым).&1&2"
                              , {&new-line}
                              , stat-line(rs-status))
        dsp-rs    = "ВСЕ товары с отрицательными партиями в свободной зоне на/в &1 &2"
        .
    end.
    when "neg-prt" then do:
        assign
        v-message = substitute("Все товары с признаками с отрицательными остатками по признакам на объекте.&1&2"
                              , {&new-line}
                              , stat-line(rs-status))
        dsp-rs    =  "ВСЕ товары с признаками с отриц. ост. по признаку на/в &1 &2"
        .
    end.
    when "nul-rest" then do:
        assign
        v-message = substitute("Все товары с нулевыми остатками на объекте.&1&2"
                              , {&new-line}
                              , stat-line(rs-status))
        dsp-rs     = "ВСЕ товары с нулевыми остатками на/в &1 &2"
        .
    end.
    when  "input" then do:
      assign
      v-message = substitute("Все товары, когда либо бывшие (или имеющиеся сейчас) на объекте.&1&2"
                              , {&new-line}
                              , stat-line(rs-status))
      dsp-rs = "ВСЕ товары, проходившие когда-либо по &1 &2"
      .
    end.
    when "with-price" then do:
      assign
      v-message = substitute("Все товары на объекте, имеющие продажную цену > 0 .&1&2"
                              , {&new-line}
                              , stat-line(rs-status))
      dsp-rs     = "ВСЕ товары, имеющие цену > 0 по &1 &2"
      .
    end.
    when "ov-req" then do:
      assign
      v-message = substitute("Товары, которые нельзя расходовать с объекта без переоценки&1" +
                            "(попадающие под действие настройки, требующей переоценки после&1" +
                            "любого прихода на объект).&1&2"
                              , {&new-line}
                              , stat-line(rs-status))
      dsp-rs = "Товары, по которым требуется переоценка после ПРИХОДА на/в &1 &2 "
      .
    end.
    WHEN "inv-req" then do:
      assign
      v-message = substitute("Товары, количество по которым изменялось со времени последней&1" +
                              "инвентаризации на объекте (своей для каждого товара).&1&2"
                              , {&new-line}
                              , stat-line(rs-status))
      dsp-rs = "Товары, по которым были ОБОРОТЫ после ИНВЕНТАРИЗАЦИИ на/в &1 &2"
      .
    end.
    when "etalon" then do:
      ASSIGN
      v-message = substitute("Все товары из справочника товаров по ТЕКУЩЕМУ объекту, цены по которым&1" +
                              "НЕ совпадают с ценами на выбранном ЭТАЛОННОМ объекте&1" +
                              "(только при условии, что цена есть на том и другом объектах).&1&2"
                              , {&new-line}
                              , stat-line(rs-status))
      dsp-rs = "Цены на/в &1 &2, не совпадающие с ценами на &3 &4"
      .
    end.
  END CASE.
  message v-message
  view-as alert-box question buttons OK-Cancel update glog.
  if not glog then do:
    run UI-on  in this-procedure.
    return error.
  end.
    {&sel-obj}
    find first buf_user-obj no-lock where
              buf_user-obj.obj-type = v-sel-obj-type
          and buf_user-obj.obj-code = v-sel-obj-code
          AND buf_user-obj.db-num = v-cntxt-db-num
          AND buf_user-obj.user-id = v-cntxt-userid  no-error .
    if not available buf_user-obj then do:
      run ui-on in this-procedure .
      return error.
    end.
    if p-method = "etalon"
    and p-curr-obj-type = v-sel-obj-type
    and p-curr-obj-code = v-sel-obj-code then do:
      message "Бессмысленно сравнивать цены для одного и того же объекта.".
      run UI-on  in this-procedure.
      return error.
    end.
    if p-method = "etalon":U then do:
      assign
      dsp-rs = replace(dsp-rs, "&1", p-curr-obj-type)
      dsp-rs = replace(dsp-rs, "&2", string(p-curr-obj-code))
      dsp-rs = replace(dsp-rs, "&3", v-sel-obj-type)
      dsp-rs = replace(dsp-rs, "&4", string(v-sel-obj-code))
      dsp-rs = substitute("&1 &2", dsp-rs, stat-line(rs-status))
      .
    end.
    else do:
      assign
      dsp-rs = replace(dsp-rs, "&1", v-sel-obj-type)
      dsp-rs = replace(dsp-rs, "&2", string(v-sel-obj-code))
      dsp-rs = substitute("&1 &2", dsp-rs, stat-line(rs-status))
      .
    end.
    run create-{1}-hist in this-procedure(input {&add-def}
                                        , input-output v-seq
                                        , input 0
                                        , input '':U
                                        , input dsp-rs
                                        , input tot-lns
                                        , input p-method
                                        , input rs-status
                                        , input '':U
                                        , input {&table_user-obj}
                                        , input buffer buf_user-obj:handle
                                        ).
end. /*doe*/

end procedure. /* object-options */

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

procedure cb_fill-lob-res-list :
define input  parameter p-full-path as character no-undo .
output to value (p-full-path).
for each {1}:
  export {1}.prod-type
        {1}.prod-code
        {1}.artic
        {1}.qnty
        .
end.
output close.
end procedure. /* cb_fill-lob-res-list */

procedure cb_fill-lob-res-list-macro :
define input  parameter p-full-path as character no-undo .
define buffer buf_{1}-hist for {1}-hist.
output to value (p-full-path).
for each buf_{1}-hist:
    export
    buf_{1}-hist.
end.
output close.
end procedure. /* cb_fill-lob-res-list-macro */

procedure cb_get-next-gds-by-gds-code :
define input parameter p-gds-code as integer no-undo .
define input parameter p-bh as handle no-undo .
define buffer buf_gds-list for {1}.
find first buf_gds-list no-lock where
          buf_gds-list.gds-code > p-gds-code no-error.
if available buf_gds-list then do:
  p-bh:buffer-create().
  p-bh:buffer-copy(buffer buf_gds-list:handle).
end.
else do:
end.
end procedure. /* cb_get-next-gds-by-gds-code */


procedure m-gds-save-db-proc :
define variable v-rid-list as character no-undo .
&if "{2}" = "managed" &then
if lookup("clobbnds_add", bttns) > 0 then do:
  run clobbnds_add in p-parent-handle
                  ( input this-procedure:handle
                   ,input {&lob-res-list}
                   ,input "gds-list"
                   ).
end.
if lookup("clobbnds_chg", bttns) > 0 then do:
  run clobbnds_chg in p-parent-handle
                  ( input this-procedure:handle
                   ).
end.
return.
&else
run ref/clobbnds.w ( input parparentproc
                    ,input this-procedure:handle
                    ,input 'b-add' /*bttns*/
                    ,input "uniq-key-rec" /*p-list-mode*/
                    ,input {&update}
                    ,input {&lob-res-list}
                    ,input 'gds-list' /*p-unique-key-rec*/
                    ,input -1 /*p-db-num*/
                    ,input-output v-rid-list) no-error.
&endif
end procedure. /* m-gds-save-db-proc */

procedure m-macros-save-db-proc :
define variable v-rid-list as character no-undo .
&if "{2}" = "managed" &then
if lookup("clobbnds_add", bttns) > 0 then do:
  run clobbnds_add in p-parent-handle
                  ( input this-procedure:handle
                   ,input {&lob-res-list-macro}
                   ,input "gds-list"
                   ).
end.
if lookup("clobbnds_chg", bttns) > 0 then do:
  run clobbnds_chg in p-parent-handle
                  ( input this-procedure:handle
                   ).
end.
return.
&else
run ref/clobbnds.w ( input parparentproc
                    ,input this-procedure:handle
                    ,input 'b-add' /*bttns*/
                    ,input "uniq-key-rec" /*p-list-mode*/
                    ,input {&update}
                    ,input {&lob-res-list-macro}
                    ,input 'gds-list' /*p-unique-key-rec*/
                    ,input -1 /*p-db-num*/
                    ,input-output v-rid-list) no-error.
&endif
end procedure. /* m-macros-save-db-proc */

procedure grplib-get-full-name-alc-type :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-full-name as character    no-undo.
    define buffer buf_alc-type       for ub.alc-type.
    find first buf_alc-type no-lock
         where buf_alc-type.alc-type-inner-code = p-node-code
    no-error.
    if not available buf_alc-type
    then do:
        undo, return error "grplib-get-full-name-alc-type: Не найден вид алкогольной продукции с кодом " + string( p-node-code ).
    end.
    assign
    p-full-name = buf_alc-type.alc-type-name
    .
end.
end procedure. /* grplib-get-full-name-alc-type */