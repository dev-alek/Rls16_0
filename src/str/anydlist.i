&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
/*DEFINE SHARED TEMP-TABLE doc-list NO-UNDO LIKE ub.units*/
/*       field doc-code   like ub.trn-doc.doc-code*/
/*       field obj-type   like ub.trn-doc.obj-type*/
/*       field obj-code   like ub.trn-doc.obj-code*/
/*       field fact-num   like ub.trn-doc.fact-num*/
/*       field fact-date  like ub.trn-doc.fact-date*/
/*       field shift-date like ub.trn-doc.shift-date*/
/*       field shift-num  like ub.trn-doc.shift-num*/
/*       field shift-name  like ub.trn-doc.shift-name*/
/*       field fact-order as decimal*/
/*       field is-trn-doc as logical*/
/*       field is-del as logical*/
/*       field doc-type   like ub.trn-doc.doc-type*/
/*       field sel-order  as integer*/
/*       field znak       as integer*/
/*       field to-del as logical*/
/*       index xpk is primary unique doc-code*/
/*       index xfact fact-num*/
/*       index xfact-date fact-date*/
/*       index znak-order znak sel-order.*/
/*DEFINE SHARED TEMP-TABLE temp-list NO-UNDO LIKE ub.units*/
/*       field fname as character format "X(30)"*/
/*       field fvalue as character*/
/*       field id as integer*/
/*       index pi is primary unique*/
/*       id*/
/*       index ifvalue fvalue. */
/*       index isdel isdel. */


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматизированное формирование списка документов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/24/01
Author: Bakhtadze Natalya
Creation date: 09/24/01

*/


/* ***************************  Definitions  ************************** */

/*define buffer ub.inkas_trn-doc for ub.trn-doc .*/

/* Parameters Definitions ---                                           */
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Автоматизированное формирование списка документов":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/doc-list.i {1} def " SHARED " }
define variable g#report-num as integer no-undo .
{ str/listhprc.i {1} multitable }

DEFINE TEMP-TABLE temp-list NO-UNDO LIKE ub.units
field fname as character format "X(40)"
field fvalue as character
field id as integer
index pi is primary unique
id.

{ gbl/flt-def.i }
{ cmp/operlist.i }
{ gbl/fltfield.i }
{ ref/cgrplbfn.i }
{ str/trdcalib.i }
{ cmp/r-page1.i new }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ str/shftnmef.i {1} shift-num temp }
{ gbl/userobjs.i }

define buffer l-{1} for {1}.

define variable v-sort-mode as character no-undo .
define variable v-sort as integer   no-undo .

define variable f-doc-name as char init "default.trn" no-undo.
define variable f-cli-name as char init "default.cli" no-undo.
define variable f-gds-name as char init "default.gds" no-undo.
define variable grp-list as char no-undo.
define variable ref-list as char no-undo.
define variable num-rec as integer init 0 no-undo.
define variable tot-lns as integer init ? no-undo.
define variable vvalue as character no-undo.
define variable vother as character no-undo.
define variable vproc-attr       as character no-undo .
define variable vfull-screen-val as character no-undo .
define variable choice as logical   no-undo init ?.
define variable v-seq as integer no-undo .
define variable v-no-hist as integer no-undo init -1.
define variable v-table-name as character no-undo .
define variable v-user-select as logical no-undo .


define variable vfillin_width as integer   no-undo .
define variable vfillin_height as integer   no-undo .
define variable vtype1 as character no-undo.
define variable vvalue1 as character no-undo.


define stream sout.
define variable CLI-REC AS RECID NO-UNDO.
DEFine VARiable RS-list-method AS CHARACTER.
define variable lns-ignore as integer no-undo .
define variable save-option as character no-undo.
define variable dcli-type like ub.trn-doc.cli-type no-undo.
define variable dcli-code like ub.trn-doc.cli-code no-undo.
define variable dcli-name like ub.clients.obj-name no-undo.
define variable ddoc-PS like ub.clients.obj-name no-undo.
define variable rs-status as character no-undo .
define variable line-mode as character no-undo .
define variable lns-cnt as integer no-undo .
define variable v-num-add          as integer no-undo .
define variable v-num-ignored      as integer no-undo .
define variable line-rec as recid no-undo .
define variable vsort as integer   no-undo .
define variable v-docs-all as logical no-undo .
define variable v-docs-cmp as logical no-undo .


/*для fbr-docs.w*/
define new shared variable br-handle as handle no-undo.
define new shared buffer f-doc for ub.fbr-doc.
DEFINE new shared QUERY br-docs FOR f-doc SCROLLING.


&scop  disp-hot-fields   if avail {1} then do: ~
    assign ed-notes = ddoc-ps. ~
    display ~
    ed-notes ~
    tot-lns @ f-tot-lns ~
    with frame ~{&frame-name~}. ~
  end.  ~
  else do: ~
    assign ed-notes = ''. ~
    display ed-notes ~
     tot-lns @ f-tot-lns ~
    with frame ~{&frame-name~}. ~
  end.


&scop sel-obj-man ~
  ref-list = "":U. ~
  ~{ gbl/uobjsman.i       ~
    parparentproc         ~
    v-cntxt-db-num        ~
    v-cntxt-userid        ~
    v-cntxt-host-code-obj ~
    v-cntxt-obj-type      ~
    v-cntxt-obj-code      ~
    v-user-select         ~
  ~}                      ~
  if not v-user-select then do: ~
    run MyEnable in this-procedure . ~
    return no-apply. ~
  end.



&scop add-operation 1
&scop del-operation 2
&scop rest-operation 3
&scop cancel-operation 4

/*define temp-table temp-list no-undo*/
/*field fname as character format "X(30)"*/
/*field fvalue as character*/
/*field id as integer*/
/*index pi is primary unique*/
/*id*/
/*index ifvalue fvalue*/
/*.*/

&scop all-options                             ~
"Текущая строка,single,                       ~
Накладная,trn-doc,                            ~
Накладные с <=датой ФАКТ<=,trn-doc-fact-date,   ~
Переоценка,price-doc,                         ~
Переоценки с <=датой ФАКТ<=,price-doc-fact-date,       ~
Продажи,inkas,                                ~
Продажи c <=датой ФАКТ<=,inkas-fact-date,    ~
Производство,fbr-doc,                         ~
Заказ/заявка,ord-doc,                         ~
Заказы/заявки с <=датой ФАКТ<=,ord-doc-fact-date,   ~
УДАЛЕННАЯ накладная,c-trn-doc,                            ~
УДАЛЕННЫЕ накладные с <=датой ФАКТ<=,c-trn-doc-fact-date,   ~
УДАЛЕННЫЕ Продажи,c-inkas,                                ~
УДАЛЕННЫЕ Продажи c <=датой ФАКТ<=,c-inkas-fact-date,    ~
С установл.атрибутом,attr,                    ~
С атрибутом= ,attr-val,                       ~
Накладные  контр-та,cli-trn-doc,              ~
Накладные гр-пы контр-тов,cli-grp-trn-doc,    ~
Накладные сп-ка контр-тов,cli-list-trn-doc,   ~
Накл. с тов. из списка,trn-gds-list,          ~
Переоц. с тов. из списка,price-gds-list,      ~
Файл,file,                                    ~
Фильтр переоценок,filter-price,               ~
Фильтр накладных,filter-trn,                  ~
Фильтр производств,filter-fbr,                ~
Фильтр продаж,filter-inkas"

&glob no-browser-option '':U

define variable f-name as char init "default.trn" no-undo.

{ cmp/listhist.i macro-list "new shared" }

FUNCTION get-table-name returns character(input p-doc-type as character):
CASE p-doc-type:
  when {&overvalue} then return {&table_price-doc}.
  when {&manufacturing} then return {&table_fbr-doc}.
  when {&cash-desk} then return {&table_inkas}.
  when ("-" + {&cash-desk}) then return {&table_c-inkas}.
  otherwise do:
   if lookup(p-doc-type, {&order-type-all}) > 0 then return {&table_ord-doc}.
   if p-doc-type begins "-"
   and lookup(entry(2, p-doc-type), {&order-type-all}) > 0 then return {&table_c-ord-doc}. /*на будущеее*/
   if p-doc-type begins "-" then return {&table_c-trn-doc}.
   return {&table_trn-doc}.
  end.
END CASE.
END FUNCTION.

&if "{1}" <> "doc-list" &then
&message anydlist.i можно вызывать только для таблицы doc-list
&endif


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-list

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES {1} temp-list

/* Definitions for BROWSE BR-list                                       */
&Scoped-define FIELDS-IN-QUERY-BR-list {1}.doc-code {1}.obj-type {1}.obj-code {1}.fact-date {1}.shift-date shift-name-no-err(buffer {1}) {1}.doc-type get-client(input {1}.doc-code, input {1}.doc-type) + string(dcli-code) dcli-name {1}.sel-order
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-list
&Scoped-define SELF-NAME BR-list
&Scoped-define OPEN-QUERY-BR-list /* OPEN QUERY {&SELF-NAME} FOR EACH {1} NO-LOCK. */ run openbr in this-procedure .
&Scoped-define TABLES-IN-QUERY-BR-list {1}
&Scoped-define FIRST-TABLE-IN-QUERY-BR-list {1}


/* Definitions for BROWSE BR-option                                     */
&Scoped-define FIELDS-IN-QUERY-BR-option temp-list.fname
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-option
&Scoped-define SELF-NAME BR-option
&Scoped-define QUERY-STRING-BR-option for each temp-list no-lock
&Scoped-define OPEN-QUERY-BR-option open query br-option for each temp-list no-lock .
&Scoped-define TABLES-IN-QUERY-BR-option temp-list
&Scoped-define FIRST-TABLE-IN-QUERY-BR-option temp-list


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-list}~
    ~{&OPEN-QUERY-BR-option}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS dsp-rs BR-option B-exit B-save B-print ~
B-hist B-lkp B-clr B-Help B-add B-del B-rest B-macro B-stop B-clear-macro ~
B-record BR-list sch-code sch-date b-up b-down ED-notes
&Scoped-Define DISPLAYED-OBJECTS dsp-rs sch-code sch-date ED-notes

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-client Dialog-Frame
FUNCTION get-client RETURNS CHARACTER
  ( input loc-doc-code as character,
    input loc-doc-type as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-print
       MENU-ITEM m_main-print   LABEL "Простой формат"
       MENU-ITEM m_doc-print    LABEL "Печать документов"
       MENU-ITEM m_ex-print     LABEL "По шаблону в EXCEL".

DEFINE MENU MENU-B-save
       MENU-ITEM m_doc-save     LABEL "Файл списка документов"
       MENU-ITEM m_xls-save     LABEL "Таблица EXCEL"
       MENU-ITEM m-title-save   LABEL "Имя списка"
       MENU-ITEM m-macros-save  LABEL "Макрос формирования списка"
       RULE
       MENU-ITEM m-rum           LABEL "Операции над списком" .

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&+Доб. строку"
     SIZE 15 BY 1 TOOLTIP "Добавление в список документов 1 строки".

DEFINE BUTTON B-clear-macro
     IMAGE-UP FILE "cmp/fstop.bmp":U
     IMAGE-DOWN FILE "cmp/fstopi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/fstopi.bmp":U
     LABEL "&[ ]"
     SIZE 4 BY 1.25 TOOLTIP "Удаление макроса формирования истории из памяти".

DEFINE BUTTON B-clr
     LABEL "Очи&стить"
     SIZE 10 BY 1 TOOLTIP "Удалить из списка все документы (строки)".

DEFINE BUTTON B-del
     LABEL "&-Удал. строку"
     SIZE 15 BY 1 TOOLTIP "Удаление из списка документов 1 строки".

DEFINE BUTTON b-down
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Переместить документ вниз".

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1 TOOLTIP "Последовательность шагов, приведшая к заполнению данного списка".

DEFINE BUTTON B-macro
     IMAGE-UP FILE "cmp/run.bmp":U
     IMAGE-DOWN FILE "cmp/runi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/runi.bmp":U
     LABEL "&>"
     SIZE 4 BY 1.25 TOOLTIP "Выполнение макроса формирования истории".

DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр текущего документа".

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1 TOOLTIP "Просмотр текущего документа".

DEFINE BUTTON B-record
     IMAGE-UP FILE "cmp/record.bmp":U
     IMAGE-DOWN FILE "cmp/recordi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/recordi.bmp":U
     LABEL "&o"
     SIZE 4 BY 1.25 TOOLTIP "Запись макроса формирования истории".

DEFINE BUTTON B-rest
     LABEL "&*Остав. строку"
     SIZE 15 BY 1 TOOLTIP "Оставить в списке документов только текущую строку".

DEFINE BUTTON B-save
     LABEL "Со&хр./Выполн."
     SIZE 15 BY 1 TOOLTIP "Сохранить список документов в текстовом файле, EXCEL".

DEFINE BUTTON B-stop
     IMAGE-UP FILE "cmp/stop.bmp":U
     IMAGE-DOWN FILE "cmp/stopi.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/stopi.bmp":U
     LABEL "&[ ]"
     SIZE 4 BY 1.25 TOOLTIP "Конец записи макроса формирования истории".

DEFINE BUTTON b-up
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Переместить документ вверх".

DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 70 BY 1.54 NO-UNDO.

DEFINE VARIABLE dsp-rs AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 75.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-tot-lns AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 10 BY .71 TOOLTIP "Кол. строк"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Начало №"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999":U
     LABEL "Факт. дата"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-list FOR
      {1} SCROLLING.

DEFINE QUERY BR-option FOR
      temp-list SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-list Dialog-Frame _FREEFORM
  QUERY BR-list DISPLAY
      {1}.doc-code COLUMN-LABEL "Документ" FORMAT "X(14)":U
      {1}.obj-type FORMAT "X(3)":U
      {1}.obj-code FORMAT "99999":U
      {1}.fact-date COLUMN-LABEL "Дата факт" FORMAT "99/99/9999":U
      {1}.shift-date COLUMN-LABEL "Дата смены" FORMAT "99/99/9999":U
      shift-name-no-err(buffer {1}) COLUMN-LABEL "№ смены" FORMAT "X(6)":U
      {1}.doc-type COLUMN-LABEL "Тип док-та" FORMAT "X(10)":U
      get-client(input {1}.doc-code, input {1}.doc-type) + string(dcli-code) COLUMN-LABEL "Контрагент" FORMAT "X(12)":U
      dcli-name COLUMN-LABEL "Название контрагента" FORMAT "X(40)":U
      {1}.sel-order COLUMN-LABEL "Пор.Номер" FORMAT ">>>,>>>,>>9":U
      {1}.is-del COLUMN-LABEL "У" FORMAT "+/":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 70 BY 16.13.

DEFINE BROWSE BR-option
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-option Dialog-Frame _FREEFORM
  QUERY BR-option DISPLAY
      temp-list.fname format "X(30)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 28 BY 21 TOOLTIP "Условие для выбора документов, которые будут добавлены/удалены/оставлены".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     dsp-rs AT ROW 1 COL 1 NO-LABEL
     B-hist AT ROW 1 COL 31
     B-Help AT ROW 1 COL 61
     B-exit AT ROW 2 COL 1
     B-save AT ROW 2 COL 11
     B-print AT ROW 2 COL 21
     B-lkp AT ROW 2 COL 41
     B-clr AT ROW 2 COL 51
     B-macro AT ROW 2 COL 61
     B-stop AT ROW 2 COL 65
     B-clear-macro AT ROW 2 COL 65
     B-record AT ROW 2 COL 65
     BR-option AT ROW 2 COL 72
     B-add AT ROW 3 COL 11
     B-del AT ROW 3 COL 26
     B-rest AT ROW 3 COL 41
     BR-list AT ROW 4.21 COL 1.25
     f-tot-lns AT ROW 3.5 COL 60 COLON-ALIGNED NO-LABEL
     sch-code AT ROW 20.5 COL 2.63
     sch-date AT ROW 20.5 COL 46.38 COLON-ALIGNED
     b-up AT ROW 20.5 COL 66
     b-down AT ROW 20.5 COL 71
     ED-notes AT ROW 21.54 COL 1 NO-LABEL
     SPACE(21.36) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список документов"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: {1} T "SHARED" NO-UNDO ub ub.units
      ADDITIONAL-FIELDS:
          field doc-code   like ub.trn-doc.doc-code
          field obj-type   like ub.trn-doc.obj-type
          field obj-code   like ub.trn-doc.obj-code
          field fact-num   like ub.trn-doc.fact-num
          field fact-date  like ub.trn-doc.fact-date
          field shift-date like ub.trn-doc.shift-date
          field shift-num  like ub.trn-doc.shift-num
          field shift-name  like ub.trn-doc.shift-name
          field fact-order as decimal
          field is-trn-doc as logical
          field is-del as logical
          field doc-type   like ub.trn-doc.doc-type
          field sel-order  as integer
          field znak       as integer
          field to-del as logical
          index xpk is primary unique doc-code
          index xfact fact-num
          index xfact-date fact-date
          index znak-order znak sel-order
      END-FIELDS.
      TABLE: temp-list T "SHARED" NO-UNDO ub ub.units
      ADDITIONAL-FIELDS:
          field fname as character format "X(30)"
          field fvalue as character
          field id as integer
          index pi is primary unique
          id
          index ifvalue fvalue
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-option 1 Dialog-Frame */
/* BROWSE-TAB BR-list B-rest Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.

ASSIGN
       B-save:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-save:HANDLE.

/* SETTINGS FOR FILL-IN dsp-rs IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       ED-notes:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN sch-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-list
/* Query rebuild information for BROWSE BR-list
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH {1} NO-LOCK. */ run openbr in this-procedure .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-list */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-option
/* Query rebuild information for BROWSE BR-option
     _START_FREEFORM
open query br-option for each temp-list no-lock .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-option */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список документов по фирме */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-clr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-clr Dialog-Frame
ON CHOOSE OF B-clr IN FRAME Dialog-Frame /* Очистить */
DO:
define variable glog as logical no-undo .
define buffer buf-{1}-hist for {1}-hist.
message
"Удаление всех строк списка. Вы уверены ?"
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
                                     , input '':U
                                     , input '0':U
                                     , input "# Список документов очищен."
                                     , input 0
                                     , input "clear"
                                     , input '':U
                                     , input '':U
                                     , input '':U
                                     , input ?
                                     ).
ed-notes:screen-value = ''.
display
tot-lns @ f-tot-lns
with frame {&frame-name}.
run MyEnable in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-down Dialog-Frame
ON CHOOSE OF b-down IN FRAME Dialog-Frame
DO:
  define buffer buf_prev_{1} for {1} .

  if available {1}
  then do:
    find first buf_prev_{1}
      where buf_prev_{1}.sel-order > {1}.sel-order
      use-index sel-order
      no-error .
    if not available buf_prev_{1}
    then do:
      message
        "Текущий документ последний в списке"
        view-as alert-box information .
    end.
    else do:
      define variable v-current-sel-order as integer   no-undo .

      assign
        v-current-sel-order    = {1}.sel-order
        {1}.sel-order          = buf_prev_{1}.sel-order
        buf_prev_{1}.sel-order = v-current-sel-order
      .

      define variable v-current-rowid as rowid no-undo .
      assign
        v-current-rowid = rowid({1})
      .
      run openbr in this-procedure .
      reposition br-list to rowid v-current-rowid no-error .
    end.
  end.
  else do:
    message
      "Документ не выбран" skip
      view-as alert-box information .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
define buffer buf_{1}-hist for {1}-hist.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
find first buf_{1}-hist no-lock where buf_{1}-hist.id = 0 no-error .
PUT  STREAM PrnLibStream unformatted
SPACE(25) "История создания списка документов "
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-host-code as integer no-undo .
define variable v-fbr-doc-next-prev as logical no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_inkas for ub.inkas.
define buffer buf_c-trn-doc for ub.c-trn-doc.
define buffer buf_ord-doc for ub.ord-doc.
 if not available {1} then do:
  message "Неправильно выбран документ."
          view-as alert-box error.
  return no-apply.
 end.
 CASE {1}.doc-type:
   when {&manufacturing} then do:
    { gbl/hostcode.i {1}.obj-type {1}.obj-code v-host-code }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_manufacturing_lookup':U
      {&cntxt-object}
      v-host-code
      {1}.obj-type
      {1}.obj-code
      0
      0
      0
      true
      glog
    }
    if not glog then   return no-apply.
    v-fbr-doc-next-prev = yes.
    find first f-doc no-lock where
              f-doc.doc-code = {1}.doc-code no-error.
    if not available f-doc then do:
      message
      substitute("Документ производства &1 уже недоступен", {1}.doc-code)
      view-as alert-box error .
      return no-apply.
    end.
    assign
    v-doc-rec = recid (f-doc)
    .
    run str/fbr-doc.w (
        input parparentproc
      , input this-procedure
      , input {&lookup}
      , input v-doc-rec
      , output v-doc-rec
      , input-output v-fbr-doc-next-prev
    ).
   end.
   when {&overvalue} then do:
     run str/showdoc.p
                (input parparentproc,
                input {1}.doc-code,
                input "",
                input "",
                input 0,
                false
                ).
    end.
    when {&cash-desk} then do:
        find first buf_inkas no-lock where
                  buf_inkas.inkas-code = {1}.doc-code no-error .
        v-doc-rec = recid(buf_inkas).
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_sale_lookup':U
          {&cntxt-object}
          buf_inkas.host-code
          buf_inkas.obj-type
          buf_inkas.obj-code
          0
          0
          0
          true
          glog
        }
        if NOT glog then return no-apply.
        run str/ink-lkp.p (input parparentproc
                    , input v-doc-rec).
    end.
    when ("-" + {&cash-desk}) then do:
      message
      "Просмотр удаленной продажи невозможен"
      view-as alert-box error .
    end.
    otherwise do:
      if lookup({1}.doc-type, {&order-type-all}) > 0 then do:
        find first buf_ord-doc no-lock where
                  buf_ord-doc.doc-code = {1}.doc-code no-error .
        v-doc-rec = recid(buf_ord-doc).
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_pmnt-ord-doc_lookup':U
          {&cntxt-object}
          buf_ord-doc.host-code
          buf_ord-doc.obj-type
          buf_ord-doc.obj-code
          0
          0
          0
          true
          glog
        }
        if NOT glog then return no-apply.
        run cus/show-ord.p ( input parParentProc
                            ,input v-doc-rec) .
      end.
      else do:
        if {1}.doc-type begins "-" then do:
          find first buf_c-trn-doc no-lock where
                    buf_c-trn-doc.doc-code = {1}.doc-code
              and  buf_c-trn-doc.is-del = yes no-error.
          if available buf_c-trn-doc then do:
            run str/c-doc.w ( input parparentproc
                            , input buf_c-trn-doc.doc-code
                            , input buf_c-trn-doc.chip-num ).
          end.
          else do:
            message
            substitute("Не удалось найти удаленный документ &1", {1}.doc-code)
            view-as alert-box error .
          end.
        end.
      run str/showdoc.p
                  (input parparentproc,
                  input {1}.doc-code,
                  input "",
                  input "",
                  input 0,
                  true
                  ).
    end.
   end.
 END CASE.
 apply "entry" to br-list in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if choice = ? then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Сохранить */
DO:
    if save-option = "" then do:
       run gbl/pop-up.p (self:handle, no) no-error.
   end.
   run proc-b-save in this-procedure (save-option) no-error.
   if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-up Dialog-Frame
ON CHOOSE OF b-up IN FRAME Dialog-Frame
DO:
  define buffer buf_prev_{1} for {1} .

  if available {1}
  then do:
    find last buf_prev_{1}
      where buf_prev_{1}.sel-order < {1}.sel-order
      use-index sel-order
      no-error .
    if not available buf_prev_{1}
    then do:
      message
        "Текущий документ первый в списке"
        view-as alert-box information .
    end.
    else do:
      define variable v-current-sel-order as integer   no-undo .

      assign
        v-current-sel-order    = {1}.sel-order
        {1}.sel-order          = buf_prev_{1}.sel-order
        buf_prev_{1}.sel-order = v-current-sel-order
      .

      define variable v-current-rowid as rowid no-undo .
      assign
        v-current-rowid = rowid({1})
      .
      run openbr in this-procedure .
      reposition br-list to rowid v-current-rowid no-error .
    end.
  end.
  else do:
    message
      "Документ не выбран" skip
      view-as alert-box information .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-list
&Scoped-define SELF-NAME BR-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-list Dialog-Frame
ON VALUE-CHANGED OF BR-list IN FRAME Dialog-Frame
DO:
  {&disp-hot-fields}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-option
&Scoped-define SELF-NAME BR-option
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-option Dialog-Frame
ON VALUE-CHANGED OF BR-option IN FRAME Dialog-Frame
DO:
  assign
  Rs-list-method = temp-list.fvalue
  .
  run proc-vc-rs-list-method in this-procedure no-error .
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_doc-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_doc-print Dialog-Frame
ON CHOOSE OF MENU-ITEM m_doc-print /* Печать документа */
DO:
  run proc-doc-print in this-procedure .
  choice = ?.
  apply "entry" to br-list in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_doc-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_doc-save Dialog-Frame
ON CHOOSE OF MENU-ITEM m_doc-save /* Файл списка документов */
DO:
  assign
  save-option = "doc-list":U.
  apply "choose" to b-save in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_ex-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_ex-print Dialog-Frame
ON CHOOSE OF MENU-ITEM m_ex-print /* По шаблону в EXCEL */
DO:
  run proc-ex-print in this-procedure .
  choice = ?.
  apply "entry" to br-list in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-macros-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-macros-save Dialog-Frame
ON CHOOSE OF MENU-ITEM m-macros-save /* Файл макрос */ DO:
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
run proc-macros in this-procedure no-error .
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_main-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_main-print Dialog-Frame
ON CHOOSE OF MENU-ITEM m_main-print /* Простой формат */
DO:
  define variable v-frame-width as integer no-undo.
  run str/docl-prn.p (input parparentproc,
                input p-curr-host-code,
                input p-curr-obj-type,
                input p-curr-obj-code,
                input "",
                output v-Frame-Width) no-error.
  if v-frame-width <= {&A4_LS} then do:
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input (if v-frame-width <= {&A4_CW0} then 0 else 8)
                                              ).
  end.
  else do:
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input (if v-frame-width <= 255 then 1 else 20)
                                              ).
  end.
  choice = ?.
  apply "entry" to br-list in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


ON CHOOSE OF MENU-ITEM m-rum /* Операции над списком */ DO:
define variable glog as logical no-undo .
{ gbl/stdbtn.i b-save "in frame {&frame-name}" }
run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input "utl/thbjrumr.w":U
    , input {&edoc} + {&delim-par} +
            ({&edoc-proc_batchwork-routing_order} + {&comma-char} +
             {&edoc-proc_batchwork-routing_price-doc} + {&comma-char} +
             {&edoc-proc_batchwork-routing_trn-doc} +  {&comma-char} +
             {&edoc-proc_batchwork-routing_inkas}
            )
              /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input "&Стоп"
    , input substitute("Операции на списком документов") ) .

END.


&Scoped-define SELF-NAME m-title-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-title-save Dialog-Frame
ON CHOOSE OF MENU-ITEM m-title-save /* ИМЯ СПИСКА */
DO:
define variable v-value as character no-undo .
  run gbl/d-prompt.w (
      'title=':u + "Введите ИМЯ СПИСКА ДОКУМЕНТОВ" + '\':u
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
                                     , input '':U
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
frame {&frame-name}:title = substitute("СПИСОК ДОКУМЕНТОВ &1", v-value).
END.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_xls-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_xls-save Dialog-Frame
ON CHOOSE OF MENU-ITEM m_xls-save /* Таблица EXCEL */
DO:
    assign
  save-option = "excel":U.
  apply "choose" to b-save in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* Начало номера */
DO:
  assign
  sch-code.
  run proc-find in this-procedure ("doc-code":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* Начало номера */
DO:
  assign
  sch-code.
  run proc-find in this-procedure ("doc-code":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON CTRL-J OF sch-date IN FRAME Dialog-Frame /* Факт. дата */
DO:
   assign
  sch-date.
  run proc-find in this-procedure ("fact-date":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON RETURN OF sch-date IN FRAME Dialog-Frame /* Факт. дата */
DO:
   assign
  sch-date.
  run proc-find in this-procedure ("fact-date":U) no-error.
  if error-status:error then do:
    return no-apply.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-list
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


on any-printable of br-list in frame {&frame-name} do:
  apply "entry" to sch-code in frame {&frame-name}.
end.
ON RETURN, MOUSE-SELECT-DBLCLICK OF br-list IN FRAME {&frame-name} DO:
    apply "choose" to b-lkp in frame {&frame-name}.
END.


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ gbl/app_help.i &disable_diasize=true }
{ gbl/diasize.i &browse-name="br-list" }

run diasize_add_browse in this-procedure
  (input  'height':u
  ,input  browse BR-option :handle
  ) .
run diasize_init in this-procedure .


{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-del }

{ cmp/ex-trn.i {1} {&frame-name} }
&glob ui-on MyEnable
{ str/an-listp.i {1} {1} trm }
{ gbl/brwrepos.i
  &browse-name=br-list
  &line-num=5
}
{ gbl/mv-clmn.i
  &ext-col      = 10
  &frame-name   = {&FRAME-NAME}
  &browse-name  = {&BROWSE-NAME}
  &table-name   = "{&table}"
  &start-column = 1
}

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
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


  run get-report-num in parparentproc ( output g#report-num ).
  assign
  line-rec = ?
  v-sort-mode = {2}
  .
  /*заполним temp-list*/
  run proc-fill-temp-list in this-procedure .
  ASSIGN
  b-save:MENU-MOUSE = 1
  b-print:MENU-MOUSE = 1
  .
  
  RUN Myenable in this-procedure .

  if v-sort-mode <> 'sort-sel-order'
  then do:
    assign
      b-up :visible   = false
      b-down :visible = false
    .
  end.
  else do:
    assign
      b-up :visible     = true
      b-down :visible   = true
      b-up :sensitive   = true
      b-down :sensitive = true
    .
    run re-move-clmnbr-list in this-procedure (input 10, 1) .
  end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_get-next-doc-by-doc-code Dialog-Frame
procedure cb_get-next-doc-by-doc-code :
define input parameter p-doc-code as character no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-bh as handle no-undo .
define buffer buf_doc-list for {1}.
find first buf_doc-list no-lock where
          buf_doc-list.doc-code = p-doc-code
     and  buf_doc-list.doc-type = p-doc-type no-error.
find next buf_doc-list use-index xpk no-error.
if available buf_doc-list then do:
  p-bh:buffer-create().
  p-bh:buffer-copy(buffer buf_doc-list:handle).
end.
else do:
end.
end procedure. /* cb_get-next-doc-by-doc-code */

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
  DISPLAY dsp-rs sch-code sch-date ED-notes f-tot-lns
      WITH FRAME Dialog-Frame.
  ENABLE dsp-rs BR-option B-exit B-save B-print B-hist B-lkp B-clr B-Help B-add
         B-del B-rest B-macro B-stop B-clear-macro B-record  BR-list sch-code ~
         sch-date b-up b-down ED-notes f-tot-lns
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-start as logical no-undo .
define variable v-recid0 as recid no-undo.
define buffer buf_temp-list for temp-list.
define buffer buf_{1}-hist for {1}-hist.
ASSIGN b-print:MENU-MOUSE IN FRAME {&FRAME-NAME} = 1.
ASSIGN b-save:MENU-MOUSE IN FRAME {&FRAME-NAME} = 1.
find first buf_{1}-hist where buf_{1}-hist.id = 0 no-error.
if available buf_{1}-hist then
assign
frame {&frame-name}:title = substitute("СПИСОК  ДОКУМЕНТОВ &1",  string(buf_{1}-hist.des, "X(60)"))
.
br-option:column-scrolling in frame {&frame-name}  = no. /*чтобы работала прокрутка*/
if tot-lns = ? then do:
  /* первоначальное заполнение истории списка при входе в него */
  v-start = yes.
  for each l-{1} :
    accumulate l-{1}.obj-code (count).
  end.
  tot-lns = (accum count l-{1}.obj-code).
  if tot-lns > 0 then do:
    find last  buf_{1}-hist no-error .
    v-seq = (if available buf_{1}-hist then buf_{1}-hist.id else 0)  + 1.
    run create-{1}-hist in this-procedure (input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
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
                                          , input '':U
                                          , input "# Исходный список документов пуст."
                                          , input tot-lns
                                          , input 'start':U
                                          , input '':U
                                          , input '':U
                                          , input '':U
                                          , input ?
                                          ).
  end.
end.
find first buf_temp-list no-lock where
            buf_temp-list.fvalue = "single".
assign
v-recid0 = recid(buf_temp-list).
{&OPEN-QUERY-br-option}
assign
RS-list-method = "single".
if v-seq > 1 then
find last buf_{1}-hist no-lock where
          buf_{1}-hist.id = (v-seq - 1)
      and  buf_{1}-hist.line = 0 no-error .
DISPLAY br-option
(if available buf_{1}-hist
then buf_{1}-hist.des
else '') @ dsp-rs
WITH FRAME {&frame-name}.
ENABLE
b-macro  when v-start
b-record when v-start
b-exit b-add b-hist b-help br-option br-list WITH FRAME {&frame-name}.
if v-start then do:
  hide
  b-stop
  b-clear-macro
  in frame {&frame-name}.
end.
v-start = no.
hide sch-code in frame {&frame-name}
sch-date in frame {&frame-name}
.
ENABLE
b-exit
b-add
b-hist
b-help
br-list
br-option
WITH FRAME {&frame-name}.
reposition br-option to recid v-recid0.
if tot-lns > 0 then
  ENABLE
  b-print
  b-rest
  b-save
  b-del
  b-lkp
  b-clr
  sch-code sch-date
  WITH FRAME {&frame-name}.
else do:
  DISABLE b-print b-rest b-save b-del b-lkp b-clr sch-code sch-date WITH FRAME {&frame-name}.
end.
if tot-lns = ? or tot-lns = 0 then do:
  hide sch-code sch-date in frame {&frame-name} .
end.
VIEW FRAME {&frame-name}.
run openbr in this-procedure .
if line-rec <> ? then
  reposition br-list to recid line-rec no-error.
/* Отключено, т.к. после reposition в updatable browse последняя строка выводится повторно на месте 1-й.
    Включается только в старом варианте списка */
/* Отключено, т.к. после reposition в updatable browse последняя строка выводится повторно на месте 1-й.
    Вместо этого скопирован следующий кусок кода из триггера на iteration-changed.
    apply "iteration-changed" to br-list in frame {&frame-name}. */
{&disp-hot-fields}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
  case v-sort-mode :
    when 'sort-doc-code':u
    then do:
      Open query br-list
        for each {1} No-LOCK
        by {1}.doc-code
        indexed-reposition
        .
    end.
    when 'sort-sel-order':u
    then do:
      Open query br-list
        for each {1} No-LOCK
        by {1}.sel-order
        indexed-reposition
        .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный порядок сортировки" v-sort-mode skip
        view-as alert-box error .
      Open query br-list
        for each {1} No-LOCK indexed-reposition
        .
    end.
  end case .
  APPLY "ENTRY" to br-list in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter p-table-name as character no-undo .
define input parameter rs-status as character no-undo .

line-mode = {&add-def}.

if rs-list-method = "single"
then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    CASE p-table-name:
      when {&table_trn-doc} then do:
        find first ub.trn-doc where rowid(ub.trn-doc) = p-rowid no-error.
        if not available ub.trn-doc then do:
          return error "Нет в БД такого документа".
        end.
      end.
      when {&table_c-trn-doc} then do:
        find first ub.c-trn-doc where rowid(ub.c-trn-doc) = p-rowid no-error.
        if not available ub.c-trn-doc then do:
          return error "Нет в БД такого УДАЛЕННОГО документа".
        end.
      end.
      when {&table_price-doc} then do:
        find first ub.price-doc where rowid(ub.price-doc) = p-rowid no-error.
        if not available ub.price-doc then do:
          return error "Нет в БД такой переоценки".
        end.
      end.
      when {&table_fbr-doc} then do:
        find first ub.fbr-doc where rowid(ub.fbr-doc) = p-rowid no-error.
        if not available ub.fbr-doc then do:
          return error "Нет в БД такого производство".
        end.
      end.
      when {&table_inkas} then do:
        find first ub.inkas where rowid( ub.inkas) = p-rowid no-error.
        if not available ub.inkas then do:
          return error "Нет в БД такой продажи".
        end.
      end.
      when {&table_ord-doc} then do:
        find first ub.ord-doc where rowid(ub.ord-doc) = p-rowid no-error.
        if not available ub.ord-doc then do:
          return error "Нет в БД такого заказа".
        end.
      end.
      when {&table_c-inkas} then do:
        find first ub.c-inkas where rowid(ub.c-inkas) = p-rowid no-error.
        if not available ub.c-inkas then do:
          return error "Нет в БД такой УДАЛЕННОЙ продажи".
        end.
      end.
    END CASE.
  end.
  else do:
  define variable v-input-output as character no-undo .
  p-table-name = {&table_trn-doc}.
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
                     ,input 'b-sel':U /*bttns*/
                     ,input '':U /*parext-doc-type*/
                     ,input ? /*paris-hold*/
                     ,input ? /*doc-rec*/
                     ,output ref-list
                     ) no-error .
  apply "entry" to br-list in frame {&frame-name}.
  if ref-list = "" then   return error.
  /* выбран документ */
  find first ub.trn-doc where recid ( ub.trn-doc) = integer (ref-list) no-lock no-error.
  end.
  if not p-from-macro and avail ub.trn-doc
  or (
      (p-from-macro and p-table-name = {&table_trn-doc} and available ub.trn-doc)
      or
      (p-from-macro and p-table-name = {&table_inkas} and available ub.inkas)
      or
      (p-from-macro and p-table-name = {&table_price-doc} and available ub.price-doc)
      or
      (p-from-macro and p-table-name = {&table_fbr-doc} and available ub.fbr-doc)
      or
      (p-from-macro and p-table-name = {&table_ord-doc} and available ub.ord-doc)
      or
      (p-from-macro and p-table-name = {&table_c-trn-doc} and available ub.c-trn-doc)
      or
      (p-from-macro and p-table-name = {&table_c-inkas} and available ub.c-inkas)
      )
  then do:
    run ex-doc in this-procedure (input (if not p-from-macro
                                         then 1
                                         else (if p-table-name begins "c-"
                                               then  (lookup(p-table-name, {&table_c-price-doc} + {&comma-char} +
                                                                          {&table_c-trn-doc} + {&comma-char} +
                                                                          {&table_c-inkas} + {&comma-char} +
                                                                          {&table_c-fbr-doc} + {&comma-char} +
                                                                          {&table_c-ord-doc} ) - 1 + 100)
                                               else  (lookup(p-table-name, {&table_price-doc} + {&comma-char} +
                                                                          {&table_trn-doc} + {&comma-char} +
                                                                          {&table_inkas} + {&comma-char} +
                                                                          {&table_fbr-doc} + {&comma-char} +
                                                                          {&table_ord-doc} ) - 1)
                                               )
                                        )
                                , input rs-list-method
                                , input rs-status
                                , input line-mode) .

    tot-lns = tot-lns + 1.
    run write-hist in this-procedure (input p-from-macro, input rs-list-method, input p-table-name, input rs-status, input line-mode).
  end.
  else do:
    return error "Нет в БД такого документа".
  end.
  run Myenable in this-procedure .
end.
else do:
    run rs-do in this-procedure (no, no, rs-list-method, p-table-name, rs-status, line-mode, v-seq - 1).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter p-table-name as character no-undo .
define input parameter rs-status as character no-undo .
define variable v-rep-rec as recid no-undo .
define variable glog as logical no-undo .
line-mode = {&deletion}.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    CASE p-table-name:
      when {&table_trn-doc} then do:
        find first ub.trn-doc where rowid(ub.trn-doc) = p-rowid no-error.
        if not available ub.trn-doc then do:
          return error "Нет в БД такого документа".
        end.
        find first {1} where {1}.doc-code = ub.trn-doc.doc-code no-error.
      end.
      when {&table_c-trn-doc} then do:
        find first ub.c-trn-doc where rowid(ub.c-trn-doc) = p-rowid no-error.
        if not available ub.c-trn-doc then do:
          return error "Нет в БД такого УДАЛЕННОГО документа".
        end.
        find first {1} where {1}.doc-code = ub.c-trn-doc.doc-code no-error.
      end.
      when {&table_price-doc} then do:
        find first ub.price-doc where rowid(ub.price-doc) = p-rowid no-error.
        if not available ub.price-doc then do:
          return error "Нет в БД такой переоценки".
        end.
        find first {1} where {1}.doc-code = ub.price-doc.doc-num no-error.
      end.
      when {&table_inkas} then do:
        find first ub.inkas where rowid( ub.inkas) = p-rowid no-error.
        if not available ub.inkas then do:
          return error "Нет в БД такой продажи".
        end.
        find first {1} where {1}.doc-code = ub.inkas.inkas-code no-error.
      end.
      when {&table_c-inkas} then do:
        find first ub.c-inkas where rowid(ub.c-inkas) = p-rowid no-error.
        if not available ub.c-inkas then do:
          return error "Нет в БД такой УДАЛЕННОЙ продажи".
        end.
        find first {1} where {1}.doc-code = ub.c-inkas.inkas-code no-error.
      end.
      when {&table_fbr-doc} then do:
        find first ub.fbr-doc where rowid(ub.fbr-doc) = p-rowid no-error.
        if not available ub.fbr-doc then do:
          return error "Нет в БД такого производства".
        end.
        find first {1} where {1}.doc-code = price-doc.doc-num no-error.
      end.
      when {&table_ord-doc} then do:
        find first ub.ord-doc where rowid(ub.ord-doc) = p-rowid no-error.
        if not available ub.ord-doc then do:
          return error "Нет в БД такого заказа".
        end.
        find first {1} where {1}.doc-code = ub.ord-doc.doc-code no-error.
      end.

    END CASE.
  end.
  if available {1} then do:
    if not p-from-macro then p-table-name = get-table-name(input {1}.doc-type).
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
    run write-hist in this-procedure (input p-from-macro, input rs-list-method, input p-table-name, input RS-STATUS, input line-mode).
    delete {1}.
    line-rec = v-rep-rec.
    run Myenable in this-procedure .
  end.
  else do:
    return error "Нет в списке документов такого документа".
  end.
end.
else do:
  glog = no.
  message "Удалить документы из списка ПО заданному УСЛОВИЮ ?   Вы уверены ?"
          view-as alert-box question buttons OK-Cancel update glog.
  if not glog then
    return error.
  run rs-do in this-procedure (no, no, rs-list-method, p-table-name, rs-status, line-mode, v-seq - 1).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-rest Dialog-Frame
PROCEDURE proc-b-rest :
define input parameter p-from-macro as logical no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter p-table-name as character no-undo .
define input parameter rs-status as character no-undo .

define variable glog as logical no-undo .
define buffer buf_{1}-hist for {1}-hist.

line-mode = {&leave}.
if rs-list-method = "single" then do:
  v-no-hist = - 1.
  if p-from-macro then do:
    CASE p-table-name:
      when {&table_trn-doc} then do:
        find first ub.trn-doc where rowid(ub.trn-doc) = p-rowid no-error.
        if not available ub.trn-doc then do:
          return error "Нет в БД такого документа".
        end.
        find first {1} where {1}.doc-code = ub.trn-doc.doc-code no-error.
      end.
      when {&table_c-trn-doc} then do:
        find first ub.c-trn-doc where rowid(ub.c-trn-doc) = p-rowid no-error.
        if not available ub.c-trn-doc then do:
          return error "Нет в БД такого УДАЛЕННОГО документа".
        end.
        find first {1} where {1}.doc-code = ub.c-trn-doc.doc-code no-error.
      end.
      when {&table_price-doc} then do:
        find first ub.price-doc where rowid(ub.price-doc) = p-rowid no-error.
        if not available ub.price-doc then do:
          return error "Нет в БД такой переоценки".
        end.
        find first {1} where {1}.doc-code = ub.price-doc.doc-num no-error.
      end.
      when {&table_inkas} then do:
        find first ub.inkas where rowid( ub.inkas) = p-rowid no-error.
        if not available ub.inkas then do:
          return error "Нет в БД такой продажи".
        end.
        find first {1} where {1}.doc-code = ub.inkas.inkas-code no-error.
      end.
      when {&table_c-inkas} then do:
        find first ub.c-inkas where rowid(ub.c-inkas) = p-rowid no-error.
        if not available ub.c-inkas then do:
          return error "Нет в БД такой УДАЛЕННОЙ продажи".
        end.
        find first {1} where {1}.doc-code = ub.c-inkas.inkas-code no-error.
      end.
      when {&table_fbr-doc} then do:
        find first ub.fbr-doc where rowid(ub.fbr-doc) = p-rowid no-error.
        if not available ub.fbr-doc then do:
          return error "Нет в БД такого производвства".
        end.
        find first {1} where {1}.doc-code = ub.fbr-doc.doc-code no-error.
      end.
      when {&table_ord-doc} then do:
        find first ub.ord-doc where rowid(ub.ord-doc) = p-rowid no-error.
        if not available ub.ord-doc then do:
          return error "Нет в БД такого заказа".
        end.
        find first {1} where {1}.doc-code = ub.ord-doc.doc-code no-error.
      end.
    END CASE.
  end.
  if available {1} then do:
    if not p-from-macro then p-table-name = get-table-name(input {1}.doc-type).
    if p-from-macro then do:
       glog = yes.
    end.
    else do:
      glog = no.
      message
      "Оставить отмеченную строку и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then return error.
    end.
    line-rec = recid ({1}).
    v-seq = 1.
    for each buf_{1}-hist:
      delete buf_{1}-hist.
    end.
    run write-hist in this-procedure (input p-from-macro, input rs-list-method, input p-table-name, input rs-status, input line-mode).
    for each {1}:
      if line-rec <> recid ({1}) then delete {1}.
    end.
    tot-lns = 1.
    run Myenable in this-procedure .
  end.
  else do:
    return error substitute("Нет в списке такого документа").
  end.
end.
else do:
  if not p-from-macro then do:
    glog = no.
    message
    "Оставить документы в списке ПО заданному УСЛОВИЮ и УДАЛИТЬ ВСЕ ОСТАЛЬНЫЕ ?   Вы уверены ?"
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then
      return no-apply.
  end.
  assign
  lns-cnt = 0
  lns-ignore = 0
  .
  run rs-do in this-procedure (no, no, rs-list-method, p-table-name, rs-status, line-mode, v-seq - 1).
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
  run Myenable in this-procedure .
  message
  "Оставлено строк :" lns-cnt skip(0)
  string(if lns-ignore <> 0
  then ("Проигнорировано строк :" + string(lns-ignore))
  else "":U)
  .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-save Dialog-Frame
PROCEDURE proc-b-save :
define input parameter loc-save-option as character no-undo.
define variable v-frame-width as integer no-undo.
define variable glog as logical no-undo .
case loc-save-option:

    when "doc-list":U then do:
      assign
      f-doc-name = "default.trn"
      glog = yes
      .
      system-dialog get-file f-doc-name
      filters "Списки документов *.trn" "*.trn"
      ask-overwrite
      save-as
      use-filename
      update glog
      default-extension "trn".
      if not glog then do:
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
      end.
      output to value (f-doc-name).
      for each {1}:
        export
        {1}.doc-code
        {1}.doc-type
        {1}.obj-type
        {1}.obj-code
        .
      end.
      output close.
    end.
    when "excel":U then do:
        do on stop  undo, return no-apply
           on error undo, return no-apply
           on quit  undo, return no-apply
        :
        run str/docl-prn.p (input parparentproc,
                      input p-curr-host-code,
                      input p-curr-obj-type,
                      input p-curr-obj-code,
                      input "excel":U,
                      output v-Frame-Width) no-error.
          run waitfram-hide in this-procedure .
       end.
    end.
end case.




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-doc-print Dialog-Frame
PROCEDURE proc-doc-print :
do
on error undo, return error return-value
:

define buffer buf_trn-doc for  ub.trn-doc .
define buffer buf_pr-doc  for  ub.price-doc .
define buffer buf_inkas   for  ub.inkas.
define buffer buf_fbr-doc for  ub.fbr-doc.
define variable v-doc-rec as   recid no-undo .
DEFINE VARIABLE v-frame-width as integer no-undo .
define variable glog as logical no-undo .

if {1}.doc-type = {&manufacturing}
or lookup({1}.doc-type, {&order-type-all}) > 0
then do:
  message
  "Нет печати для документов производства и заказок/заявок!"
  view-as alert-box .
  return.
end.

if {1}.doc-type = {&Overvalue} then do: /*переоценка*/
   find first buf_pr-doc no-lock  where buf_pr-doc.doc-num = {1}.doc-code no-error .
    v-doc-rec = recid (buf_pr-doc).
    run rep/pr-dprn.w ( input parparentproc
                       ,input v-doc-rec).
end.
else do:
  if {1}.doc-type = {&cash-desk} then do: /*продажа*/
          find first buf_inkas no-lock where
                     buf_inkas.inkas-code = {1}.doc-code No-error.
    run rep/sale-prn.p (
            input parparentproc
          , input recid(buf_inkas)
          , input yes
          ).
  end.
  else do: /* накладные */
    find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = {1}.doc-code no-error .
    v-doc-rec = recid (buf_trn-doc).

    case buf_trn-doc.doc-type
    :
      when {&income}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_income_print':U
          {&cntxt-object}
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          0
          0
          0
          true
          glog
        }
      end.
      when {&expense}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_expense_print':U
          {&cntxt-object}
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          0
          0
          0
          true
          glog
        }
      end.
      when {&write-off}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_write-off_print':U
          {&cntxt-object}
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          0
          0
          0
          true
          glog
        }
      end.
      when {&inventory}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_inventory_print':U
          {&cntxt-object}
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          0
          0
          0
          true
          glog
        }
      end.
      when {&return}
      then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_return_print':U
          {&cntxt-object}
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          0
          0
          0
          true
          glog
        }
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип документа" skip
          "Тип документа" buf_trn-doc.doc-type skip
          "Код документа" buf_trn-doc.doc-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    if not glog then return error.

    define buffer buf1_trn-doc for ub.trn-doc  .
    define variable v-spis-recid as character no-undo .
    v-spis-recid = "".
    for each {1} :
        find first buf1_trn-doc no-lock  where buf1_trn-doc.doc-code = {1}.doc-code no-error .
        v-spis-recid = v-spis-recid + string(recid (buf1_trn-doc)) + "," .
    end.
    run rep/doc-prn.p (
          input parparentproc
        , input ?
        , input v-spis-recid
    ).
  end.
end.
choice = ?.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-ex-print Dialog-Frame
PROCEDURE proc-ex-print :

  do
  on error undo, return error return-value
  :
    run str/doc-xls.p ( input parparentproc, input p-curr-obj-type, input p-curr-obj-code) .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-file-list-methods Dialog-Frame
procedure proc-file-list-methods :
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .
define variable ss as character no-undo .
define variable b-c as integer no-undo.
define variable imp-art like ub.goods.artic no-undo .
define variable imp-type like ub.goods.prod-type no-undo.
define variable imp-code like ub.goods.prod-code no-undo.
define variable imp-doc-code like ub.trn-doc.doc-code no-undo.
define variable imp-doc-type as character no-undo.
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
    (input  buf_{1}-hist.item_ /* p-search-file-name */
    ,output v-full-path         /* p-full-path        */
    ,output v-path              /* p-path             */
    ,output v-file-name         /* p-file-name        */
    ,output v-file-name-no-ext  /* p-file-name-no-ext */
    ,output v-file-name-ext     /* p-file-name-ext    */
    ) no-error .
  if error-status:error then do: end. else do:

    input stream sout from value (v-full-path).

    CASE rs-list-method:
      when "cli-list-trn-doc" then do:
        repeat:
          import stream sout imp-type imp-code no-error.
          for each ub.trn-doc where ub.trn-doc.cli-type = imp-type
                            and ub.trn-doc.cli-code = imp-code no-lock:
              run ex-doc in this-procedure(input 1, input rs-list-method, input rs-status, input line-mode)  .
          end. /*for each*/
        end. /*repeat*/
      end.
      when "trn-gds-list" or
      when "price-gds-list" then do:
        define variable v-doc-code as character no-undo .
      repeat:
        import stream sout  imp-type imp-code imp-art no-error.
        if rs-list-method = "price-gds-list" then do:
          for each ub.price-list No-LOCK WHERE
                    ub.price-list.artic = imp-art
                AND ub.price-list.prod-type = imp-type
                AND ub.price-list.prod-code = imp-code
                and ub.price-list.main-price = yes:
            if ub.price-list.doc-num <> v-doc-code then do:
              find first ub.price-doc no-lock where
                          ub.price-doc.doc-num = ub.price-list.doc-num no-error.
              if avail ub.price-doc then do:
                run ex-doc in this-procedure(input 0, input rs-list-method, input rs-status, input line-mode) .
              end.
              v-doc-code = ub.price-list.doc-num.
            end. /*if ub.price-list.doc-num <> v-doc-code then do:*/
          end. /*for each ub.price-list No-LOCK WHERE*/
        end.
        else do:
          for each ub.db no-lock,
              each ub.clients no-lock where
                  ub.clients.db-num = ub.db.db-num,
             each ub.doc-line No-LOCK WHERE
                    ub.doc-line.artic = imp-art
                AND ub.doc-line.prod-type = imp-type
                AND ub.doc-line.prod-code = imp-code
                and ub.doc-line.obj-type = ub.clients.obj-type
                and ub.doc-line.obj-code = ub.clients.obj-code:
             if ub.doc-line.doc-code <> v-doc-code then do:
              find first ub.trn-doc no-lock where
                        ub.trn-doc.doc-code = ub.doc-line.doc-code no-error.
              if avail ub.trn-doc then do:
                run ex-doc in this-procedure(input 1, input rs-list-method, input rs-status, input line-mode) .
              end.
              v-doc-code = ub.doc-line.doc-code.
            end. /*if ub.doc-line.doc-code <> v-doc-code then do:*/
          end. /*          for each ub.db no-lock,*/
        end.
      end. /*repeat*/
      end.
      when "file" then do:
        repeat:
          import stream sout imp-doc-code imp-doc-type no-error.
          CASE imp-doc-type:
            when {&overvalue} then do:
              find first ub.price-doc no-lock where
                        ub.price-doc.doc-num = imp-doc-code No-error.
              if available ub.price-doc then run ex-doc in this-procedure (input 0, input rs-list-method, input rs-status, input line-mode).
            end.
            when {&cash-desk} then do:
              find first ub.inkas no-lock where
                        ub.inkas.inkas-code = imp-doc-code No-error.
              if available ub.inkas then run ex-doc in this-procedure (input 2, input rs-list-method, input rs-status, input line-mode).
            end.
            when "-" + {&cash-desk} then do:
              find first ub.c-inkas no-lock where
                        ub.c-inkas.inkas-code = imp-doc-code No-error.
              if available ub.c-inkas then run ex-doc in this-procedure (input 102, input rs-list-method, input rs-status, input line-mode).
            end.
            when {&manufacturing} then do:
              find first ub.fbr-doc no-lock where
                        ub.fbr-doc.doc-code = imp-doc-code No-error.
              if available ub.fbr-doc then run ex-doc in this-procedure (input 3, input rs-list-method, input rs-status, input line-mode).
            end.
            otherwise do:
              if lookup(imp-doc-type, {&order-type-all}) > 0 then do:
                find first ub.ord-doc no-lock where
                          ub.ord-doc.doc-code = imp-doc-code No-error.
                if available ub.ord-doc then run ex-doc in this-procedure (input 4, input rs-list-method, input rs-status, input line-mode).
              end.
              else do:
                if imp-doc-type begins "-" then do:
                  find first ub.c-trn-doc no-lock where
                            ub.c-trn-doc.doc-code = imp-doc-code No-error.
                  if available ub.trn-doc then run ex-doc in this-procedure (input 101, input rs-list-method, input rs-status, input line-mode).
                end.
                else do:
              find first ub.trn-doc no-lock where
                        ub.trn-doc.doc-code = imp-doc-code No-error.
              if available ub.trn-doc then run ex-doc in this-procedure (input 1, input rs-list-method, input rs-status, input line-mode).
            end.
              end.
            end.
          END CASE. /*      CASE imp-doc-type:*/
        end. /*repeat:*/
      end. /*when file*/
    END CASE.
    input stream sout close.
    {&assign-nums}.
  end.
end. /*doe*/
end procedure. /* proc-file-list-methods */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find Dialog-Frame
PROCEDURE proc-find :
define input parameter loc-find as character no-undo.

case loc-find:
  when "doc-code":U then do:
    if last-event:label = "Ctrl-J" then
        find next l-{1} no-lock where
                   l-{1}.doc-code begins sch-code no-error.
    else
        find first l-{1} no-lock where
                   l-{1}.doc-code begins sch-code no-error.
  end.
  when "fact-date":U then do:
    if last-event:label = "Ctrl-J" then
        find next l-{1} no-lock where
                   l-{1}.fact-date = sch-date no-error.
    else
        find first l-{1} no-lock where
                   l-{1}.fact-date = sch-date no-error.
  end.
end case.
if available l-{1} then do:
  line-rec = recid (l-{1}).
  reposition br-list to recid line-rec no-error.
  apply "value-changed" to br-list in frame {&frame-name}.
end.
else do:
  message
  "Строка не найдена."
  view-as alert-box error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-macros Dialog-Frame
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
  f-name = "default.trm"
  glog = yes
  .
  system-dialog get-file f-name
  filters "Макрос создания списка документов *.trm" "*.trm"
  ask-overwrite
  save-as
  use-filename
  update glog
  default-extension "trm".
  if not glog then do:
    apply "entry" to br-list in frame {&frame-name}.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Сохранение макроса формирования списка документов.    ЖДИТЕ...").
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
end procedure. /* proc-macro */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-vc-rs-list-method Dialog-Frame
PROCEDURE proc-vc-rs-list-method :
define variable v-operation as integer no-undo .
define variable ii as integer no-undo.
define variable glog as logical no-undo .
define variable v-recs as integer no-undo .
define variable v-line as integer no-undo .
define variable v-item as character no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable v-tot-lns as integer no-undo .
define variable v-temp-seq as integer no-undo .
define variable v-message as character no-undo .
define variable grp-path as character no-undo .
define variable v-input-output as character no-undo .
define variable v-ref-rec as recid no-undo .
define variable v-grp-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
define variable f-name as char init "default.trn" no-undo.
define variable v-date1 as date no-undo .
define variable v-date2 as date no-undo .
define buffer buf_{1}-hist for {1}-hist.
define buffer buf_inkas for ub.inkas.
define buffer buf_c-inkas for ub.c-inkas.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_c-trn-doc for ub.c-trn-doc.
define buffer buf_price-doc for ub.price-doc.
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

v-no-hist = - 1.
if  temp-list.fvalue = "single" then
run Myenable in this-procedure .
else do:
  v-no-hist = 0.
  case  rs-list-method:
    when "attr" or when "attr-val" then do:
      run trig-attr in this-procedure (input rs-list-method) no-error.
      if error-status:error then do:
        run MyEnable in this-procedure .
        return error.
      end.
    end. /*when attr*/
    when "trn-doc" then do:
      glog = yes.
      message "Одна или несколько Накладных."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
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
      if ref-list = "" then do:
        run Myenable in this-procedure .
        return error.
      end.
      run str/sortdctp.p (input-output ref-list, input no).
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find buf_trn-doc where recid (buf_trn-doc) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Документ : &1 &2 &3 &4 № &5 от &6"
                              , buf_trn-doc.doc-type
                              , buf_trn-doc.status_
                              , buf_trn-doc.obj-type
                              , buf_trn-doc.obj-code
                              , buf_trn-doc.doc-code
                              , string (buf_trn-doc.doc-date, '99/99/9999')
                              )
          v-item     = '':U
          v-tbl-name = {&table_trn-doc}
          v-bh       = buffer buf_trn-doc:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Документы :")
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
                                , buf_trn-doc.doc-type
                                , buf_trn-doc.status_
                                , buf_trn-doc.obj-type
                                , buf_trn-doc.obj-code
                                , buf_trn-doc.doc-code
                                , string (buf_trn-doc.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = {&table_trn-doc}
            v-bh       = buffer buf_trn-doc:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input {&table_trn-doc}
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
    end. /*when trn-doc*/
    when "trn-doc-fact-date" then do:
      glog = yes.
      message "Все накладные с датойФАКТ за период дат"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
       {&sel-obj-man}
      message
      "Выберите период дат"
      view-as alert-box.
      run gbl/get-per.w ( output glog
                        ,input-output v-date1
                        ,input-output v-date2
                        ) no-error.
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("Документы  с датой ФАКТ от &1 до &2:"
                        ,  string(v-date1, "99/99/9999")
                        , string(v-date2, "99/99/9999"))
      v-item     =  ''
      v-tbl-name = '':U
      v-bh       = ?
      v-tot-lns = tot-lns
      .
      v-no-hist = 0.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input {&table_trn-doc}
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      v-seq  = v-temp-seq.
      for each buf_userobjs_temp-user-obj
      on error undo, return no-apply
      :
        num-rec = num-rec + 1.
        v-no-hist = num-rec.
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("Документы  с датой ФАКТ от &1 до &2 &3&4:"
                            , string(v-date1, "99/99/9999")
                            , string(v-date2, "99/99/9999")
                            , buf_userobjs_temp-user-obj.obj-type
                            , buf_userobjs_temp-user-obj.obj-code
                            )
        v-item     =  buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                      string(buf_userobjs_temp-user-obj.obj-code) + {&delim-key} +
                      string(v-date1, "99/99/9999") + {&delim-key} +
                      string(v-date2, "99/99/9999")
        v-tbl-name = ''
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input {&table_trn-doc}
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
      end. /*do num-rec*/
    end. /*when "trn-doc-fact-date" then do:*/
    when "c-trn-doc" then do:
      glog = yes.
      message "Одна или несколько УДАЛЕННЫХ Накладных."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run str/calldocs.w
                    (input parparentproc
                    ,input {&c-work} /*parlistmode*/
                    ,input ? /*parstat*/
                    ,input ? /*partype*/
                    ,input ?
                    ,input ? /*parinternal*/
                    ,input 'b-sel,b-mark':U /*bttns*/
                    ,input '':U /*parext-doc-type*/
                    ,input ? /*paris-hold*/
                    ,input ? /*doc-rec*/
                    ,input v-cntxt-obj-type
                    ,input v-cntxt-obj-code
                    ,output ref-list
                    ) no-error .
      if ref-list = "" then do:
        run Myenable in this-procedure .
        return error.
      end.

      run str/sortdctp.p (input-output ref-list, input yes).

      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find buf_c-trn-doc where recid (buf_c-trn-doc) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("УДАЛЕННЫЙ Документ : &1 &2 &3 &4 № &5 от &6"
                              , buf_c-trn-doc.doc-type
                              , buf_c-trn-doc.status_
                              , buf_c-trn-doc.obj-type
                              , buf_c-trn-doc.obj-code
                              , buf_c-trn-doc.doc-code
                              , string (buf_c-trn-doc.doc-date, '99/99/9999')
                              )
          v-item     = '':U
          v-tbl-name = {&table_c-trn-doc}
          v-bh       = buffer buf_c-trn-doc:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("УДАЛЕННЫЕ Документы :")
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
                                , buf_c-trn-doc.doc-type
                                , buf_c-trn-doc.status_
                                , buf_c-trn-doc.obj-type
                                , buf_c-trn-doc.obj-code
                                , buf_c-trn-doc.doc-code
                                , string (buf_c-trn-doc.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = {&table_c-trn-doc}
            v-bh       = buffer buf_c-trn-doc:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input {&table_c-trn-doc}
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
    end. /*when c-trn-doc*/
    when "c-trn-doc-fact-date" then do:
      glog = yes.
      message "Все УДАЛЕННЫЕ накладные с датойФАКТ за период дат"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
       {&sel-obj-man}
      message
      "Выберите период дат"
      view-as alert-box.
      run gbl/get-per.w ( output glog
                        ,input-output v-date1
                        ,input-output v-date2
                        ) no-error.
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("УДАЛЕННЫЕ Документы  с датой ФАКТ от &1 до &2:"
                        ,  string(v-date1, "99/99/9999")
                        , string(v-date2, "99/99/9999"))
      v-item     =  ''
      v-tbl-name = '':U
      v-bh       = ?
      v-tot-lns = tot-lns
      .
      v-no-hist = 0.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input {&table_c-trn-doc}
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      v-seq  = v-temp-seq.
      for each buf_userobjs_temp-user-obj
      on error undo, return no-apply
      :
        num-rec = num-rec + 1.
        v-no-hist = num-rec.
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("УДАЛЕННЫЕ Документы  с датой ФАКТ от &1 до &2 &3&4:"
                            , string(v-date1, "99/99/9999")
                            , string(v-date2, "99/99/9999")
                            , buf_userobjs_temp-user-obj.obj-type
                            , buf_userobjs_temp-user-obj.obj-code
                            )
        v-item     =  buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                      string(buf_userobjs_temp-user-obj.obj-code) + {&delim-key} +
                      string(v-date1, "99/99/9999") + {&delim-key} +
                      string(v-date2, "99/99/9999")
        v-tbl-name = ''
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input {&table_c-trn-doc}
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
      end. /*do num-rec*/
    end. /*when "c-trn-doc-fact-date" then do:*/
    when "price-doc" then do:
      glog = yes.
      message "Одна или несколько Переоценок."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return no-apply.
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
        run MyEnable.
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
          find buf_price-doc where recid (buf_price-doc) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Переоценка : &1 &2 &3 № &4 от &5"
                              , buf_price-doc.status_
                              , buf_price-doc.obj-type
                              , buf_price-doc.obj-code
                              , buf_price-doc.doc-num
                              , string(buf_price-doc.doc-date, '99/99/9999')
                              )
          v-item     = '':U
          v-tbl-name = {&table_price-doc}
          v-bh       = buffer buf_price-doc:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Переоценки :")
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
                                , buf_price-doc.status_
                                , buf_price-doc.obj-type
                                , buf_price-doc.obj-code
                                , buf_price-doc.doc-num
                                , string(buf_price-doc.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = {&table_price-doc}
            v-bh       = buffer buf_price-doc:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input {&table_price-doc}
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
    end. /*when price-doc*/
    when "price-doc-fact-date" then do:
      glog = yes.
      message "Все переоценки с датойФАКТ за период дат"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
       {&sel-obj-man}
      message
      "Выберите период дат"
      view-as alert-box.
      run gbl/get-per.w ( output glog
                        ,input-output v-date1
                        ,input-output v-date2
                        ) no-error.
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("Документы  с датой ФАКТ от &1 до &2:"
                        ,  string(v-date1, "99/99/9999")
                        , string(v-date2, "99/99/9999"))
      v-item     =  ''
      v-tbl-name = '':U
      v-bh       = ?
      v-tot-lns = tot-lns
      .
      v-no-hist = 0.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input {&table_price-doc}
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      v-seq  = v-temp-seq.
      for each buf_userobjs_temp-user-obj
      on error undo, return no-apply
      :
        num-rec = num-rec + 1.
        v-no-hist = num-rec.
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("Документы  с датой ФАКТ от &1 до &2 &3&4:"
                            , string(v-date1, "99/99/9999")
                            , string(v-date2, "99/99/9999")
                            , buf_userobjs_temp-user-obj.obj-type
                            , buf_userobjs_temp-user-obj.obj-code
                            )
        v-item     =  buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                      string(buf_userobjs_temp-user-obj.obj-code) + {&delim-key} +
                      string(v-date1, "99/99/9999") + {&delim-key} +
                      string(v-date2, "99/99/9999")
        v-tbl-name = ''
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input {&table_price-doc}
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
      end. /*do num-rec*/
    end. /*when "price-doc-fact-date" then do:*/
    when "inkas" then do:
      glog = yes.
      message
      "Одна или несколько отчетов о Продаже."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      ref-list = "" .
      run str/salelist.w (input parparentproc
                    ,input "b-sel,b-mark"
                    ,input {&company}
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input-output ref-list) no-error .
      if ref-list = "" then do:
        run Myenable in this-procedure .
        return no-apply.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find buf_inkas where recid (buf_inkas) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
            dsp-rs = substitute("Продажа: &1 &2&3 &4"
                           , buf_inkas.inkas-code
                           , buf_inkas.obj-type
                           , buf_inkas.obj-code
                           , string (buf_inkas.doc-date)
                           )
          v-item     = '':U
          v-tbl-name = {&table_inkas}
          v-bh       = buffer buf_inkas:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Продажа: ")
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
            dsp-rs = substitute("&1", buf_inkas.inkas-code)
            v-item     = '':U
            v-tbl-name = {&table_inkas}
            v-bh       = buffer buf_inkas:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input {&table_inkas}
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
    end. /*when inkas*/
    when "inkas-fact-date" then do:
      glog = yes.
      message "Все  док-ты продажи с датойФАКТ за период дат"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
       {&sel-obj-man}
      message
      "Выберите период дат"
      view-as alert-box.
      run gbl/get-per.w ( output glog
                        ,input-output v-date1
                        ,input-output v-date2
                        ) no-error.
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("Документы  с датой ФАКТ от &1 до &2:"
                        ,  string(v-date1, "99/99/9999")
                        , string(v-date2, "99/99/9999"))
      v-item     =  ''
      v-tbl-name = '':U
      v-bh       = ?
      v-tot-lns = tot-lns
      .
      v-no-hist = 0.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input {&table_inkas}
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      v-seq  = v-temp-seq.
      for each buf_userobjs_temp-user-obj
      on error undo, return no-apply
      :
        num-rec = num-rec + 1.
        v-no-hist = num-rec.
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("Документы  с датой ФАКТ от &1 до &2 &3&4:"
                            , string(v-date1, "99/99/9999")
                            , string(v-date2, "99/99/9999")
                            , buf_userobjs_temp-user-obj.obj-type
                            , buf_userobjs_temp-user-obj.obj-code
                            )
        v-item     =  buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                      string(buf_userobjs_temp-user-obj.obj-code) + {&delim-key} +
                      string(v-date1, "99/99/9999") + {&delim-key} +
                      string(v-date2, "99/99/9999")
        v-tbl-name = ''
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input {&table_inkas}
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
      end. /*do num-rec*/
    end. /*when "inkas-fact-date" then do:*/
    when "c-inkas" then do:
      glog = yes.
      message
      "Один или несколько УДАЛЕННЫХ отчетов о Продаже."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      ref-list = "" .
      run str/salclist.w (input parparentproc
                    ,input "b-sel,b-mark"
                    ,input ({&deleted} + {&comma-char} + {&company})
                    ,input ''
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input-output ref-list) no-error .
      if ref-list = "" then do:
        run Myenable in this-procedure .
        return no-apply.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find buf_c-inkas where recid (buf_c-inkas) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
            dsp-rs = substitute("УДАЛЕННАЯ Продажа: &1 &2&3 &4"
                           , buf_c-inkas.inkas-code
                           , buf_c-inkas.obj-type
                           , buf_c-inkas.obj-code
                           , string (buf_c-inkas.doc-date)
                           )
          v-item     = '':U
          v-tbl-name = {&table_c-inkas}
          v-bh       = buffer buf_c-inkas:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("УДАЛЕННАЯ Продажа: ")
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
            dsp-rs = substitute("&1", buf_c-inkas.inkas-code)
            v-item     = '':U
            v-tbl-name = {&table_c-inkas}
            v-bh       = buffer buf_c-inkas:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input {&table_c-inkas}
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
    end. /*when c-inkas*/
    when "c-inkas-fact-date" then do:
      glog = yes.
      message "Все УДАЛЕННЫЕ док-ты продажи с датойФАКТ за период дат"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
       {&sel-obj-man}
      message
      "Выберите период дат"
      view-as alert-box.
      run gbl/get-per.w ( output glog
                        ,input-output v-date1
                        ,input-output v-date2
                        ) no-error.
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("УДАЛЕННЫЕ продажи с датой ФАКТ от &1 до &2:"
                        ,  string(v-date1, "99/99/9999")
                        , string(v-date2, "99/99/9999"))
      v-item     =  ''
      v-tbl-name = '':U
      v-bh       = ?
      v-tot-lns = tot-lns
      .
      v-no-hist = 0.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input {&table_c-inkas}
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      v-seq  = v-temp-seq.
      for each buf_userobjs_temp-user-obj
      on error undo, return no-apply
      :
        num-rec = num-rec + 1.
        v-no-hist = num-rec.
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("УДАЛЕННЫЕ продажи с датой ФАКТ от &1 до &2 &3&4:"
                            , string(v-date1, "99/99/9999")
                            , string(v-date2, "99/99/9999")
                            , buf_userobjs_temp-user-obj.obj-type
                            , buf_userobjs_temp-user-obj.obj-code
                            )
        v-item     =  buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                      string(buf_userobjs_temp-user-obj.obj-code) + {&delim-key} +
                      string(v-date1, "99/99/9999") + {&delim-key} +
                      string(v-date2, "99/99/9999")
        v-tbl-name = ''
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input {&table_c-inkas}
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
      end. /*do num-rec*/
    end. /*when "c-inkas-fact-date" then do:*/
    when "fbr-doc" then do:
      glog = yes.
      message "Один или несколько документов Производства."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return no-apply.
      end.
      run str/fbr-docs.w ( input parparentproc
                          ,input  ?
                          ,input (if v-docs-all
                                  then {&work}
                                  else {&g___object}
                                  )
                          ,input-output ref-list).
      if ref-list = "" then do:
        run MyEnable.
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
          find buf_fbr-doc where recid (buf_fbr-doc) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Производство : &1 &2 &3 № &4 от &5"
                              , buf_fbr-doc.status_
                              , buf_fbr-doc.obj-type
                              , buf_fbr-doc.obj-code
                              , buf_fbr-doc.doc-code
                              , string(buf_fbr-doc.doc-date, '99/99/9999')
                              )
          v-item     = '':U
          v-tbl-name = {&table_fbr-doc}
          v-bh       = buffer buf_fbr-doc:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Производства :")
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
                                , buf_fbr-doc.status_
                                , buf_fbr-doc.obj-type
                                , buf_fbr-doc.obj-code
                                , buf_fbr-doc.doc-code
                                , string(buf_fbr-doc.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = {&table_fbr-doc}
            v-bh       = buffer buf_fbr-doc:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input {&table_fbr-doc}
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
    end. /*when fbr-doc*/
    when "ord-doc" then do:
      glog = yes.
      message "Один или несколько Заказов/заявок."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run ref/all-zakz.w (
        input   parParentProc
        ,input   "all":U
        ,input   "all":U
        ,input   "firm"
        ,input   ?
        ,input   "b-sel,b-mark"
        ,input   ""
        ,output  ref-list ) .

      if ref-list = "" then do:
        run Myenable in this-procedure .
        return error.
      end.
      v-recs = num-entries(ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then do:
          num-rec = 1 .
        end.
        if num-rec > 0 then do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find buf_ord-doc where recid (buf_ord-doc) = v-ref-rec no-lock.
        end.
        if v-recs = 1 then do:
          assign
          v-temp-seq = v-seq
          v-line     = 0
          dsp-rs = substitute("Заказ : &1 &2 &3 &4 № &5 от &6"
                              , buf_ord-doc.doc-type
                              , buf_ord-doc.status_
                              , buf_ord-doc.obj-type
                              , buf_ord-doc.obj-code
                              , buf_ord-doc.doc-code
                              , string (buf_ord-doc.doc-date, '99/99/9999')
                              )
          v-item     = '':U
          v-tbl-name = {&table_ord-doc}
          v-bh       = buffer buf_ord-doc:handle
          v-tot-lns = tot-lns
          .
        end.
        else do:
          if num-rec = 0 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Заказы/заявки :")
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
                                , buf_ord-doc.doc-type
                                , buf_ord-doc.status_
                                , buf_ord-doc.obj-type
                                , buf_ord-doc.obj-code
                                , buf_ord-doc.doc-code
                                , string (buf_ord-doc.doc-date, '99/99/9999')
                                )
            v-item     = '':U
            v-tbl-name = {&table_ord-doc}
            v-bh       = buffer buf_ord-doc:handle
            v-tot-lns = tot-lns + num-rec
            .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input {&table_ord-doc}
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
    end. /*when ord-doc*/
    when "ord-doc-fact-date" then do:
      glog = yes.
      message "Все заказы/заявки с датойФАКТ за период дат"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
       {&sel-obj-man}
      message
      "Выберите период дат"
      view-as alert-box.
      run gbl/get-per.w ( output glog
                        ,input-output v-date1
                        ,input-output v-date2
                        ) no-error.
      assign
      v-temp-seq = v-seq
      v-line     = 0
      dsp-rs = substitute("Заказы/заявки с датой ФАКТ от &1 до &2:"
                        ,  string(v-date1, "99/99/9999")
                        , string(v-date2, "99/99/9999"))
      v-item     =  ''
      v-tbl-name = '':U
      v-bh       = ?
      v-tot-lns = tot-lns
      .
      v-no-hist = 0.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-temp-seq
                                          , input v-line
                                          , input {&table_ord-doc}
                                          , input '':U
                                          , input dsp-rs
                                          , input v-tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input v-item
                                          , input v-tbl-name
                                          , input v-bh
                                          ).
      v-seq  = v-temp-seq.
      for each buf_userobjs_temp-user-obj
      on error undo, return no-apply
      :
        num-rec = num-rec + 1.
        v-no-hist = num-rec.
        assign
        v-temp-seq = v-seq - 1
        v-line     = num-rec
        dsp-rs = substitute("Заказы/заявки с датой ФАКТ от &1 до &2 &3&4:"
                            , string(v-date1, "99/99/9999")
                            , string(v-date2, "99/99/9999")
                            , buf_userobjs_temp-user-obj.obj-type
                            , buf_userobjs_temp-user-obj.obj-code
                            )
        v-item     =  buf_userobjs_temp-user-obj.obj-type + {&delim-key} +
                      string(buf_userobjs_temp-user-obj.obj-code) + {&delim-key} +
                      string(v-date1, "99/99/9999") + {&delim-key} +
                      string(v-date2, "99/99/9999")
        v-tbl-name = ''
        v-bh       = ?
        v-tot-lns = tot-lns + num-rec
        .
        run create-{1}-hist in this-procedure(input {&add-def}
                                            , input-output v-temp-seq
                                            , input v-line
                                            , input {&table_ord-doc}
                                            , input '':U
                                            , input dsp-rs
                                            , input v-tot-lns
                                            , input rs-list-method
                                            , input rs-status
                                            , input v-item
                                            , input v-tbl-name
                                            , input v-bh
                                            ).
      end. /*do num-rec*/
    end. /*when "ord-doc-fact-date" then do:*/
    when "cli-trn-doc" or when "cli-grp-trn-doc" then do:
      glog = yes.
      if rs-list-method = "cli-grp-trn-doc" then do:
        glog = yes.
        message "Накладные контрагентов из 1 или нескольких групп."
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run MyEnable.
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
        message "Накладные 1 или нескольких контрагентов."
        view-as alert-box question buttons OK-Cancel update glog.
        if not glog then do:
          run MyEnable in this-procedure .
          return error.
        end.
        grp-list = "". /* чтоб не было ложного срабатывания следующего if */
        run ref/cli-all.w ( input parparentproc
                      ,input "b-sel,b-mark"
                      ,input  ?
                      ,input  ?
                      ,input  ?
                      ,input  ?
                      ,input  ?
                      ,input  ?
                      ,output ref-list) .
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
            dsp-rs = substitute("Группа контрагентов: &1", grp-path)
            v-item     = '':U
            v-tbl-name = {&table_cli-grp}
            v-bh       = buffer ub.cli-grp:handle
            v-tot-lns = tot-lns
            .
          end.
          else do:
            if num-rec = 0 then do:
              assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs = substitute("Группы контрагентов: ")
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
              v-bh       = buffer ub.cli-grp:handle
              v-tot-lns = tot-lns + num-rec
              .
            end.
          end.
          v-no-hist = (if num-rec = 1 then 0 else num-rec).
          run create-{1}-hist in this-procedure(input {&add-def}
                                              , input-output v-temp-seq
                                              , input v-line
                                              , input {&table_trn-doc}
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
            find ub.clients where recid ( ub.clients) = v-ref-rec no-lock.
          end.
          if v-recs = 1 then do:
            assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs = substitute("Контрагент :&1", ub.clients.obj-name)
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
              dsp-rs = substitute("Контрагент : ")
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
              dsp-rs = substitute("&1", ub.clients.obj-name)
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
                                              , input {&table_trn-doc}
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
        run MyEnable in this-procedure .
        return error.
      end.
    end. /*cli-trn-doc */
    when "cli-list-trn-doc"  then do:
      glog = yes.
      message
      "Все документы по контрагентам " skip
      "из ранее сохраненного в файле списка клиентов" skip
      "(по всем объектам фирмы за все время работы программы)" skip
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure .
        return no-apply.
      end.
      system-dialog get-file f-cli-name
      filters "Списки контрагентов *.cli" "*.cli"
      title "Выберите файл списка"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      /* use-filename */
      update glog
      default-extension "cli".
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input '':U
                                          , input substitute("Файл списка контрагентов: &1", f-cli-name)
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-cli-name
                                          , input '':U
                                          , input ?
                                          ).
    end.
    when "trn-gds-list"
    or
    when "price-gds-list" then do:
      glog = yes.
      if rs-list-method = "trn-gds-list" then
      message
      "Все накладные с товарами из сохраненного в файле списка товаров."
      view-as alert-box question buttons OK-Cancel update glog.
      else
      message
      "Все переоценки с товарами из сохраненного в файле списка товаров."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure .
        return no-apply.
      end.
      system-dialog get-file f-gds-name
      filters "Списки товаров *.gds" "*.gds"
      title "Выберите файл списка"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      /* use-filename */
      update glog
      default-extension "gds".
      if not glog then do:
        run MyEnable in this-procedure .
        return error.
      end.
      if rs-list-method = "trn-gds-list" then
      dsp-rs = substitute("Накладные на товары списка : &1", f-gds-name).
      else
      dsp-rs = substitute("Переоценки на товары списка : &1", f-gds-name).
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input '':U
                                          , input dsp-rs
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-gds-name
                                          , input '':U
                                          , input ?
                                          ).
    end.
    when "file" then do:
      glog = yes.
      message
      "Все документы из ранее сохраненного в файле списка."
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        run Myenable in this-procedure .
        return no-apply.
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
        run MyEnable in this-procedure .
        return error.
      end.
      run create-{1}-hist in this-procedure(input {&add-def}
                                          , input-output v-seq
                                          , input 0
                                          , input '':U
                                          , input '':U
                                          , input substitute("Файл списка : &1", f-doc-name)
                                          , input tot-lns
                                          , input rs-list-method
                                          , input rs-status
                                          , input f-doc-name
                                          , input '':U
                                          , input ?
                                          ).
    end. /*when file*/
    WHEN "FILTER-trn"
    or
    when "FILTER-price"
    or
    when "filter-inkas"
    or
    when "filter-fbr"
    THEN DO:
      CASE rs-list-method:
        when "filter-trn" then run trig-filter-trn in this-procedure no-error.
        when "filter-price" then run trig-filter-price in this-procedure no-error.
        when "filter-inkas" then run trig-filter-inkas in this-procedure no-error.
        when "filter-fbr" then run trig-filter-fbr in this-procedure no-error.
      END CASE.
      if error-status:error then do:
        run MyEnable in this-procedure .
        return error.
      end.
    END. /*WHEN FILTER*/
  end case.
  if tot-lns <> 0 then do:
    run get-operation in this-procedure (input dsp-rs, output v-operation).
    CASE v-operation:
      when {&add-operation} then do:
        run proc-b-add in this-procedure(input no
                                        ,input ?
                                        ,input rs-list-method
                                        ,input v-table-name
                                        ,input rs-status) no-error  .
      end.
      when {&del-operation} then do:
        run proc-b-del in this-procedure(input no
                                        ,input ?
                                        ,input rs-list-method
                                        ,input v-table-name
                                        ,input rs-status ) no-error  .
      end.
      when {&rest-operation} then do:
        run proc-b-rest in this-procedure(input no
                                         ,input ?
                                         ,input rs-list-method
                                         ,input v-table-name
                                         ,input rs-status) no-error  .
      end.
      otherwise do:
        assign
        dsp-rs = "":U.
        run MyEnable in this-procedure .
        return error.
      end.
    END CASE.
  end.
  assign
  rs-list-method =  temp-list.fvalue
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
    run proc-b-add in this-procedure(input no
                                    ,input ?
                                    ,input rs-list-method
                                    ,input v-table-name
                                    ,input rs-status)  .
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rs-do Dialog-Frame
PROCEDURE rs-do :
define input parameter p-from-macro as logical no-undo .
define input parameter p-step as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter p-table-name as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-id      as integer no-undo .

define variable imp-ART like ub.goods.ARTIC no-undo.
define variable imp-type like ub.goods.prod-type no-undo.
define variable imp-code like ub.goods.prod-code no-undo.
define variable imp-doc-code like ub.trn-doc.doc-code no-undo.
define variable imp-doc-type as character no-undo.
define variable grp-path like ub.goods.grp-name no-undo.
define variable v-report-num as integer no-undo .
define variable glog as logical no-undo .

define variable v-rowid   as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-obj-type as character  no-undo.
define variable v-obj-code as integer    no-undo.
DEFINE VARIABLE v-attr-code          as character           no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-date-from  as date no-undo .
define variable v-date-to  as date no-undo .
define buffer buf_{1}-hist for {1}-hist.
define buffer buf_user-obj for ub.user-obj.

do
on error undo, return error return-value
:

assign
lns-cnt = 0
lns-ignore = 0
v-num-add  = 0
v-num-ignored = 0
tot-lns = (if line-mode = {&leave} then 0 else tot-lns)
.
run write-hist in this-procedure (input p-from-macro, input rs-list-method, input p-table-name, input RS-STATUS, input line-mode).
if session:set-wait-state( "COMPILER" )  then .
dsp-rs:fgcolor in frame {&frame-name} = 12.
case rs-list-method:
  when "attr"
  or
  when "attr-val" then do:
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U no-error .
    assign
    v-attr-code = entry(1, buf_{1}-hist.item_, {&delim-key})
    vvalue = (if rs-list-method = "attr" then '':U else entry(2, buf_{1}-hist.item_, {&delim-key}))
    no-error
    .
    if error-status:error then do:
    end.
    else do:
        for each ub.doc-attr No-LOCK WHERE
              ub.doc-attr.attr-code = v-attr-code,
            first ub.trn-doc no-lock where
                 ub.trn-doc.doc-code = ub.doc-attr.doc-code
        :

         if rs-list-method = "attr-val" then do:
           { str/tdat-val.i
               ub.trn-doc.doc-code
               v-attr-code
               vvalue1
               vtype1
           }
           if vvalue1 <> vvalue then NEXT.
         end.
       run ex-doc in this-procedure(input 1, input rs-list-method, input rs-status, input line-mode).  /* 0 1 2 sv */
      end. /*for each ub.clients no-lock,*/
      {&assign-nums}.
    end.
  end.
  WHEN "PRICE-DOC" THEN DO:
    glog = no.
    _jj:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next _jj.
      find first ub.price-doc no-lock where
                rowid(ub.price-doc) = v-rowid no-error.
      if not avail ub.price-doc then next _jj.
      run ex-DOC in this-procedure(input 0, input rs-list-method, input rs-status, input line-mode).
      {&assign-nums}.
    end. /* for each buf_1-hist */
  END. /*WHEN "PRICE-DOC"*/
  when "price-doc-fact-date" then do:
     for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      assign
      v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
      v-date-from =     date(entry(3, buf_{1}-hist.item_, {&delim-key}))
      v-date-to = date(entry(4, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-obj-type
              AND buf_user-obj.obj-code = v-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each ub.price-doc no-lock where
                 ub.price-doc.obj-type = buf_user-obj.obj-type
             and ub.price-doc.obj-code = buf_user-obj.obj-code
             and ub.price-doc.fact-date >= v-date-from
             and ub.price-doc.fact-date <= v-date-to:
            run ex-DOC in this-procedure(input 0, input rs-list-method, input rs-status, input line-mode) .
            {&assign-nums}.
          end.
        end. /*if available buf_user-obj then do:*/
      end.
    end. /*for each bf_hist*/
  end. /*when "price-doc-fact-date" then do:*/
  WHEN "fbr-DOC" THEN DO:
    glog = no.
    _jj:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next _jj.
      find first ub.fbr-doc no-lock where
                rowid(ub.fbr-doc) = v-rowid no-error.
      if not avail ub.fbr-doc then next _jj.
      run ex-DOC in this-procedure(input 3, input rs-list-method, input rs-status, input line-mode).
      {&assign-nums}.
    end. /* for each buf_1-hist */
  END. /*WHEN "fbr-DOC"*/
  WHEN "TRN-DOC" THEN DO:
    glog = no.
    _ii:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next _ii.

      find first ub.trn-doc no-lock where
              rowid(ub.trn-doc) = v-rowid no-error.
      if not avail ub.trn-doc then next _ii.
      run ex-DOC in this-procedure(input 1, input rs-list-method, input rs-status, input line-mode) .
      {&assign-nums}.
    end. /* for each buf_{1}-hist */
  END. /*"TRN-DOC"*/
  when "trn-doc-fact-date" then do:
     for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      assign
      v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
      v-date-from =     date(entry(3, buf_{1}-hist.item_, {&delim-key}))
      v-date-to = date(entry(4, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-obj-type
              AND buf_user-obj.obj-code = v-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each ub.trn-doc no-lock where
                 ub.trn-doc.obj-type = buf_user-obj.obj-type
             and ub.trn-doc.obj-code = buf_user-obj.obj-code
             and ub.trn-doc.fact-date >= v-date-from
             and ub.trn-doc.fact-date <= v-date-to:
            run ex-DOC in this-procedure(input 1, input rs-list-method, input rs-status, input line-mode) .
            {&assign-nums}.
          end.
        end. /*if available buf_user-obj then do:*/
      end.
    end. /*for each bf_hist*/
  end. /*when "trn-doc-fact-date" then do:*/
  WHEN "c-trn-doc" THEN DO:
    glog = no.
    _ii:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next _ii.

      find first ub.c-trn-doc no-lock where
              rowid(ub.c-trn-doc) = v-rowid no-error.
      if not avail ub.c-trn-doc then next _ii.
      run ex-DOC in this-procedure(input 101, input rs-list-method, input rs-status, input line-mode) .
      {&assign-nums}.
    end. /* for each buf_{1}-hist */
  END. /*"c-trn-doc"*/
  when "c-trn-doc-fact-date" then do:
     for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      assign
      v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
      v-date-from =     date(entry(3, buf_{1}-hist.item_, {&delim-key}))
      v-date-to = date(entry(4, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-obj-type
              AND buf_user-obj.obj-code = v-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each ub.c-trn-doc no-lock where
                 ub.c-trn-doc.obj-type = buf_user-obj.obj-type
             and ub.c-trn-doc.obj-code = buf_user-obj.obj-code
             and ub.c-trn-doc.fact-date >= v-date-from
             and ub.c-trn-doc.fact-date <= v-date-to
             and ub.c-trn-doc.is-del = yes:
            run ex-DOC in this-procedure(input 101, input rs-list-method, input rs-status, input line-mode) .
            {&assign-nums}.
          end.
        end. /*if available buf_user-obj then do:*/
      end.
    end. /*for each bf_hist*/
  end. /*when "c-trn-doc-fact-date" then do:*/
  WHEN "inkas" THEN DO:
   for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
      and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid}  next.
      find first ub.inkas no-lock where
                rowid( ub.inkas) = v-rowid no-error.
      if available ub.inkas then do:
         run ex-DOC in this-procedure(input 2, input rs-list-method, input rs-status, input line-mode).
      end. /* do num-rec = 1 to */
      {&assign-nums}.
    end.
  END. /*WHEN "inkas"*/
  when "inkas-fact-date" then do:
     for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      assign
      v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
      v-date-from =     date(entry(3, buf_{1}-hist.item_, {&delim-key}))
      v-date-to = date(entry(4, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-obj-type
              AND buf_user-obj.obj-code = v-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each ub.inkas no-lock where
                 ub.inkas.obj-type = buf_user-obj.obj-type
             and ub.inkas.obj-code = buf_user-obj.obj-code
             and ub.inkas.fact-date >= v-date-from
             and ub.inkas.fact-date <= v-date-to:
            run ex-DOC in this-procedure(input 2, input rs-list-method, input rs-status, input line-mode) .
            {&assign-nums}.
          end.
        end. /*if available buf_user-obj then do:*/
      end.
    end. /*for each bf_hist*/
  end. /*when "inkas-fact-date" then do:*/
  WHEN "c-inkas" THEN DO:
   for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
      and  buf_{1}-hist.item_ <> '':U:
      {&get-rowid}  next.
      find first ub.c-inkas no-lock where
                rowid(ub.c-inkas) = v-rowid no-error.
      if available ub.c-inkas then do:
         run ex-DOC in this-procedure(input 102, input rs-list-method, input rs-status, input line-mode).
      end. /* do num-rec = 1 to */
      {&assign-nums}.
    end.
  END. /*WHEN "c-inkas"*/
  when "c-inkas-fact-date" then do:
     for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      assign
      v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
      v-date-from =     date(entry(3, buf_{1}-hist.item_, {&delim-key}))
      v-date-to = date(entry(4, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-obj-type
              AND buf_user-obj.obj-code = v-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each ub.c-inkas no-lock where
                 ub.c-inkas.obj-type = buf_user-obj.obj-type
             and ub.c-inkas.obj-code = buf_user-obj.obj-code
             and ub.c-inkas.fact-date >= v-date-from
             and ub.c-inkas.fact-date <= v-date-to
             and ub.c-inkas.is-del = yes :
            run ex-DOC in this-procedure(input 102, input rs-list-method, input rs-status, input line-mode) .
            {&assign-nums}.
          end.
        end. /*if available buf_user-obj then do:*/
      end.
    end. /*for each bf_hist*/
  end. /*when "c-inkas-fact-date" then do:*/
  WHEN "ord-doc" THEN DO:
    glog = no.
    _ii:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next _ii.

      find first ub.ord-doc no-lock where
              rowid(ub.ord-doc) = v-rowid no-error.
      if not avail ub.ord-doc then next _ii.
      run ex-DOC in this-procedure(input 4, input rs-list-method, input rs-status, input line-mode) .
      {&assign-nums}.
    end. /* for each buf_{1}-hist */
  END. /*"ord-doc"*/
  when "ord-doc-fact-date" then do:
     for each buf_{1}-hist where
            buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_ <> '':U:
      assign
      v-obj-type = entry(1, buf_{1}-hist.item_, {&delim-key})
      v-obj-code = integer(entry(2, buf_{1}-hist.item_, {&delim-key}))
      v-date-from =     date(entry(3, buf_{1}-hist.item_, {&delim-key}))
      v-date-to = date(entry(4, buf_{1}-hist.item_, {&delim-key}))
      no-error
      .
      if error-status:error then do: end. else do:
        find first buf_user-obj no-lock where
                  buf_user-obj.obj-type = v-obj-type
              AND buf_user-obj.obj-code = v-obj-code
              AND buf_user-obj.db-num = v-cntxt-db-num
              AND buf_user-obj.user-id = v-cntxt-userid
              no-error .
        if available buf_user-obj then do:
          for each ub.ord-doc no-lock where
                 ub.ord-doc.obj-type = buf_user-obj.obj-type
             and ub.ord-doc.obj-code = buf_user-obj.obj-code
             and ub.ord-doc.fact-date >= v-date-from
             and ub.ord-doc.fact-date <= v-date-to:
            run ex-DOC in this-procedure(input 4, input rs-list-method, input rs-status, input line-mode) .
            {&assign-nums}.
          end.
        end. /*if available buf_user-obj then do:*/
      end.
    end. /*for each bf_hist*/
  end. /*when "ord-doc-fact-date" then do:*/
  when "cli-trn-doc" then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next.
      find ub.clients where rowid ( ub.clients) = v-rowid no-lock.
      for each ub.trn-doc no-lock where
                ub.trn-doc.cli-type = ub.clients.obj-type AND
                ub.trn-doc.cli-code = ub.clients.obj-code:
        run ex-doc in this-procedure(input 1, input rs-list-method, input rs-status, input line-mode) .
      end. /*for each*/
      {&assign-nums}.
    end.
  end. /*cli-grp-trn-doc*/
  when "cli-grp-trn-doc" then do:
    for each buf_{1}-hist where
             buf_{1}-hist.id = p-id
        and  buf_{1}-hist.item_  <> '':U:
      {&get-rowid} next.
      find ub.cli-grp where rowid (ub.cli-grp) = v-rowid no-lock.
      grp-path = "".
      run cli-grplib-get-full-name in this-procedure (ub.cli-grp.node-code, output grp-path).
      for each ub.clients where
                ub.clients.grp-name begins grp-path no-lock,
          each ub.trn-doc no-lock where
                ub.trn-doc.cli-type = ub.clients.obj-type AND
                ub.trn-doc.cli-code = ub.clients.obj-code:
        run ex-doc in this-procedure(input 1, input rs-list-method, input rs-status, input line-mode).
      end. /*for each*/
     {&assign-nums}.
     end.
   end. /*when cli-trn-doc */
   when "cli-list-trn-doc"
   or
   when "trn-gds-list"
   or
   when "price-gds-list"
   or
   when "file"
   then do:
     run proc-file-list-methods in this-procedure(input p-from-macro, input rs-list-method, input rs-status, input line-mode, input p-id). .
   end.
  when "filter-trn"
  or
  when "filter-price"
  or
  when "filter-inkas"
  then do:
    define variable v-filter-var as character no-undo .
    find first buf_{1}-hist where
             buf_{1}-hist.id = p-id
         AND buf_{1}-hist.item_ <> '':U .
    run proc-write-filter-expression-var in this-procedure ( input buf_{1}-hist.item_ , output v-filter-var).
    CASE rs-list-method:
      when "filter-trn" then
      run gbl/doc-fill.p (input 1
                   ,input "Формирование списка по фильтру накладных (без учета сортировки)"
                   ,input rs-list-method
                   ,input rs-status
                   ,input line-mode
                   ,input p-curr-host-code
                   ,input {&table_trn-doc}
                   ,input v-filter-var
                   ,output lns-cnt
                   ,output line-rec
                   )
                  .
      when "filter-price" then
      run gbl/doc-fill.p (input 0
                   ,input "Формирование списка по фильтру переоценок (без учета сортировки)"
                   ,input rs-list-method
                   ,input rs-status
                   ,input line-mode
                   ,input p-curr-host-code
                   ,input {&table_price-doc}
                   ,input v-filter-var
                   ,output lns-cnt
                   ,output line-rec
                   ).
      when "filter-fbr" then
      run gbl/doc-fill.p (input 0
                   ,input "Формирование списка по фильтру производств (без учета сортировки)"
                   ,input rs-list-method
                   ,input rs-status
                   ,input line-mode
                   ,input p-curr-host-code
                   ,input {&table_fbr-doc}
                   ,input v-filter-var
                   ,output lns-cnt
                   ,output line-rec
                   ).
      when "filter-inkas" then
      run gbl/doc-fill.p (input 0
                   ,input "Формирование списка по фильтру продаж (без учета сортировки)"
                   ,input rs-list-method
                   ,input rs-status
                   ,input line-mode
                   ,input p-curr-host-code
                   ,input {&table_inkas}
                   ,input v-filter-var
                   ,output lns-cnt
                   ,output line-rec
                   ).
    END CASE.
    {&assign-nums}.
  end.
END CASE.
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
end CASE.
if line-mode <> {&leave} then
  run Myenable in this-procedure.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-attr Dialog-Frame
PROCEDURE trig-attr :
define input parameter rs-list-method as character no-undo .
define variable ii as integer no-undo.
define variable glog as logical no-undo .
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
DEFINE VARIABLE v-attr-code          as character           no-undo .
define variable vproc-attr       as character no-undo .
define variable vfull-screen-val as character no-undo .


assign
ref-list = ""
vattr-codes = ""
vattr-labels = ""
vvalue = ""
.
define variable v-ii as integer   no-undo .
v-ii = num-entries({&trdcattr-list}) .
DO ii = 1 to v-ii :
    { str/tdat-cod.i
        "entry( ii, {&trdcattr-list} )"
        vtype
        vformat
        vfillin_width
        vfillin_height
        vlabel
        vuser-can-edit
        voutput-display
        vother
        vproc-attr
        vfull-screen-val
        vsort
        no-error
    }

    if not error-status :error and voutput-display = yes then do:
        assign
        vattr-codes = vattr-codes + {&tilda-char} + entry(ii, {&trdcattr-list})
        vattr-labels = vattr-labels + {&tilda-char} + vlabel
        .

    end.
end.

run gbl/d-list.w ("b-sel":U,
            "Выберите атрибут документа",
             vattr-codes,
             vattr-labels,
             {&tilda-char},
             "":U,
             output v-attr-code).

if v-attr-code = "" then do:
  return error.
end.

glog = yes.
if rs-list-method = "attr" then do:
    { str/tdat-cod.i
        v-attr-code
        vtype
        vformat
        vfillin_width
        vfillin_height
        vlabel
        vuser-can-edit
        voutput-display
        vother
        vproc-attr
        vfull-screen-val
        v-sort
        no-error
    }

    message
    "Все документы с установленным атрибутом " + vlabel
     view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs = substitute("ВСЕ документы с установленным атрибутом &1", vlabel)
    v-item = v-attr-code
    .
end.
else do:
    { str/tdat-cod.i
        v-attr-code
        vtype
        vformat
        vfillin_width
        vfillin_height
        vlabel
        vuser-can-edit
        voutput-display
        vother
        vproc-attr
        vfull-screen-val
        v-sort
    }

    run gbl/d-prompt.w (
      'title=':u + "Значение атрибута документа" + '\':u
    + 'text1=':u + vlabel + '\':u
    + 'format=' + (if vtype = {&type-log} then "yes/no" else vformat) + '\':u
    + 'type=' + vtype + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=':u  + string(vfillin_width) + '\':u
    + 'fillin_height=':u + string(vfillin_height) + '\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output vvalue
    ).
    if return-value = 'false':U then do:
      return error.
    end.
    message
    substitute("Все документы с атрибутом &1 = &2" , vlabel, vvalue)
     view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
      return error.
    end.
    assign
    dsp-rs = substitute("ВСЕ документы с атрибутом &1 = &2", vlabel, vvalue)
    v-item = v-attr-code + {&delim-key} + vvalue
    .
end.
v-no-hist = 0.
run create-{1}-hist in this-procedure(input {&add-def}
                                    , input-output v-seq
                                    , input 0
                                    , input {&table_trn-doc}
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-filter-inkas Dialog-Frame
PROCEDURE trig-filter-inkas :
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable filter-name as char no-undo.
define variable where-phrase as char no-undo.
define variable sort-phrase as char no-undo.
define variable where-phrase-rus as char no-undo.
define variable sort-phrase-rus as char no-undo.

glog = yes.
message
"Все продажи, выбранные в соответствии с заданным фильтром."
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "doc-list_salelist" + {&delim-par} + "Список продаж" + {&delim-par} + "no"
.

assign
tbl = {&table_inkas}
join-tbl = ''
fld = ""
lab = ""
spr = ""
dim = '0'
.

run fltfield-add in this-procedure('inkas-code', '', '',
                                  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('doc-date', 'Дата', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('fact-date', 'Факт', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('shift-date', '', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('shift-name', '№ смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('acc-date', 'Проводка', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('bge-date', 'Вн.проводка', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('netto', 'Сумма нетто', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('discnt', 'Скидка', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('tot-doc', 'Сумма брутто', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('num-chk', 'Кол-во чеков', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('office', 'Услуги', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('qnty', 'Кол-во товара', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run gbl/filter.w ( input parparentproc
                  ,input c-point
                  ,input tbl
                  ,input join-tbl
                  ,input fld
                  ,input lab
                  ,input spr
                  ,input dim).
run gbl/flt-get.p (input c-point
              , output v-flt-rec
              , output filter-name
              , output where-phrase
              , output sort-phrase
              , output where-phrase-rus
              , output sort-phrase-rus
              ) .
if v-flt-rec = ? then do:
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run create-{1}-hist in this-procedure(input {&add-def}
                                      , input-output v-seq
                                      , input 0
                                      , input {&table_inkas}
                                      , input '':U
                                      , input substitute("Фильтр продаж: &1 &2", ubflt.filter.naim, ubflt.filter.where-ysl-rus)
                                      , input tot-lns
                                      , input rs-list-method
                                      , input rs-status
                                      , input ubflt.filter.where-ysl
                                      , input '':U
                                      , input ?
                                      ).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-filter-fbr Dialog-Frame
PROCEDURE trig-filter-fbr :
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable filter-name as char no-undo.
define variable where-phrase as char no-undo.
define variable sort-phrase as char no-undo.
define variable where-phrase-rus as char no-undo.
define variable sort-phrase-rus as char no-undo.

glog = yes.
message
"Все производства, выбранные в соответствии с заданным фильтром."
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "doc-list_prdoclist" + {&delim-par} + "Список производств" + {&delim-par} + "no"
.

assign
tbl = {&table_fbr-doc}
join-tbl = ''
fld = ""
lab = ""
spr = ""
dim = '0'
.

run fltfield-add in this-procedure('status_', 'Статус', 'pr-stat',
                                  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('doc-code', '', '',
                                  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('doc-date', 'Дата', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('fact-date', 'Факт', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('shift-date', '', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('shift-name', '№ смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


run gbl/filter.w ( input parparentproc
                  ,input c-point
                  ,input tbl
                  ,input join-tbl
                  ,input fld
                  ,input lab
                  ,input spr
                  ,input dim).
run gbl/flt-get.p (input c-point
              , output v-flt-rec
              , output filter-name
              , output where-phrase
              , output sort-phrase
              , output where-phrase-rus
              , output sort-phrase-rus
              ) .
if v-flt-rec = ? then do:
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run create-{1}-hist in this-procedure(input {&add-def}
                                      , input-output v-seq
                                      , input 0
                                      , input {&table_fbr-doc}
                                      , input '':U
                                      , input substitute("Фильтр документов производства: &1 &2", ubflt.filter.naim, ubflt.filter.where-ysl-rus)
                                      , input tot-lns
                                      , input rs-list-method
                                      , input rs-status
                                      , input ubflt.filter.where-ysl
                                      , input '':U
                                      , input ?
                                      ).

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-filter-price Dialog-Frame
PROCEDURE trig-filter-price :
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable filter-name as char no-undo.
define variable where-phrase as char no-undo.
define variable sort-phrase as char no-undo.
define variable where-phrase-rus as char no-undo.
define variable sort-phrase-rus as char no-undo.

glog = yes.
message
"Все переоценки, выбранные в соответствии с заданным фильтром."
view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "doc-list_prdoclist" + {&delim-par} + "Список переоценок" + {&delim-par} + "no"
.

assign
tbl = {&table_price-doc}
join-tbl = ''
fld = ""
lab = ""
spr = ""
dim = '0'
.

run fltfield-add in this-procedure('status_', 'Статус', 'pr-stat',
                                  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('doc-num', '', '',
                                  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('doc-date', 'Дата', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('fact-date', 'Факт', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('shift-date', '', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('shift-name', '№ смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('rest-qnty', 'Кол-во', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('rest-sale', 'Сумма До пер-ки (баз. вал.)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('sale-base', 'Сумма по док. (баз. вал.)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('creid', '', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('fact-num', 'Порядок закрытия', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


run gbl/filter.w ( input parparentproc
                  ,input c-point
                  ,input tbl
                  ,input join-tbl
                  ,input fld
                  ,input lab
                  ,input spr
                  ,input dim).
run gbl/flt-get.p (input c-point
              , output v-flt-rec
              , output filter-name
              , output where-phrase
              , output sort-phrase
              , output where-phrase-rus
              , output sort-phrase-rus
              ) .
if v-flt-rec = ? then do:
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run create-{1}-hist in this-procedure(input {&add-def}
                                      , input-output v-seq
                                      , input 0
                                      , input {&table_price-doc}
                                      , input '':U
                                      , input substitute("Фильтр переоценок: &1 &2", ubflt.filter.naim, ubflt.filter.where-ysl-rus)
                                      , input tot-lns
                                      , input rs-list-method
                                      , input rs-status
                                      , input ubflt.filter.where-ysl
                                      , input '':U
                                      , input ?
                                      ).

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-filter-trn Dialog-Frame
PROCEDURE trig-filter-trn :
define variable glog as logical no-undo .
define variable v-flt-rec as recid no-undo .
define variable filter-name as char no-undo.
define variable where-phrase as char no-undo.
define variable sort-phrase as char no-undo.
define variable where-phrase-rus as char no-undo.
define variable sort-phrase-rus as char no-undo.

glog = yes.
message "Все накладные, выбранные в соответствии с заданным фильтром (без учета сортировки)."
        view-as alert-box question buttons OK-Cancel update glog.
if not glog then do:
  return error.
end.
assign
c-point = "doc-list_trndoclist" + {&delim-par} + "Список накладных" + {&delim-par} + "no"
.

assign
tbl = {&table_trn-doc}
join-tbl = ''
fld = ""
lab = ""
spr = ""
dim = '0'
.

run fltfield-add in this-procedure('doc-type', 'Тип', 'trn-type',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ext-doc-type', 'Расш.тип', 'ext-doc-type',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', 'trn-stat',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('flag_', 'OK', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-code', 'Номер', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', 'Дата док-та', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Дата факт', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Дата смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ смены', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code', 'Контрагент', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('boss', 'Менеджер', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-qnty', 'Кол-во по док.', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-qnty', 'Кол-во факт', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', 'Сумма (вал)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-calc', 'Скидка (вал)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-rubl', 'Сумма ({&abbr_rub})', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt-rubl', 'Скидка ({&abbr_rub})', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt-pc', 'Скидка (%)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt-type', 'Тип скидки', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-fact', 'Сумма (факт)', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-code', 'Код оплаты', 'pay',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('internal', 'Внутренняя', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-name', 'Название контр-а', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('creid', 'Создал', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('agnt', 'Исполнитель', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('wrkr', 'Кладовщик', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('out-code', 'На док-т', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('acc-date', 'Проводка', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('base-rate', 'Курс', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('inv-num', 'Инвойс', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ord-num', 'Заказ', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', 'Услуги', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('print-rubl', '{&abbr_rublevy_firstshift}', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ship-num', 'Отгрузка', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ship-date', 'Дата отгрузки', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ov', 'Акт', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-ov', 'Сумма акта', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('exch-code', 'Валюта', 'cur',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-num', 'Порядок закрытия', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', 'Примечание', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run gbl/filter.w ( input parparentproc
                  ,input c-point
                  ,input tbl
                  ,input join-tbl
                  ,input fld
                  ,input lab
                  ,input spr
                  ,input dim).
run gbl/flt-get.p (input c-point
              , output v-flt-rec
              , output filter-name
              , output where-phrase
              , output sort-phrase
              , output where-phrase-rus
              , output sort-phrase-rus
              ) .
if v-flt-rec = ? then do:
  return error.
end.
else do:
  find ubflt.filter where recid (ubflt.filter) = v-flt-rec no-lock.
  run create-{1}-hist in this-procedure(input {&add-def}
                                      , input-output v-seq
                                      , input 0
                                      , input {&table_trn-doc}
                                      , input '':U
                                      , input substitute("Фильтр накладных: &1 &2", ubflt.filter.naim, ubflt.filter.where-ysl-rus)
                                      , input tot-lns
                                      , input rs-list-method
                                      , input rs-status
                                      , input ubflt.filter.where-ysl
                                      , input '':U
                                      , input ?
                                      ).

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-hist Dialog-Frame
PROCEDURE write-hist :
/* запись истории формирования списка */
define input parameter p-from-macro as logical no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter p-table-name as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define variable v-ii as integer no-undo .
define variable v-temp-seq as integer no-undo .
if rs-list-method = "single" then do:
  if v-no-hist < 0 then do:
    run create-{1}-hist in this-procedure(input {&add-def}
                                        , input-output v-seq
                                        , input 0
                                        , input p-table-name
                                        , input get-hist-mode(line-mode)
                                        , input substitute("Документ &1 от &2 &3&4 (факт.дата &5)"
                                                          , {1}.doc-code
                                                          , string({1}.doc-date, "99/99/9999")
                                                          , {1}.obj-type
                                                          , {1}.obj-code
                                                          , string({1}.fact-date, "99/99/9999")
                                                          )
                                        , input tot-lns
                                        , input rs-list-method
                                        , input rs-status
                                        , input (p-table-name + {&delim-key} + {1}.doc-code)
                                        , input ''
                                        , input ?
                                        ).
  end.
  else do:
    v-temp-seq = v-seq - 1.
    do v-ii = 0 to v-no-hist:
      run create-{1}-hist in this-procedure(input ({&update} + {&delim-par} + 'mode':U)
                                          , input-output v-temp-seq
                                          , input v-ii
                                          , input p-table-name
                                          , input get-hist-mode(line-mode)
                                          , input substitute("Документ &1 от &2 &3&4 (факт.дата &5)"
                                                            , {1}.doc-code
                                                            , string({1}.doc-date, "99/99/9999")
                                                            , {1}.obj-type
                                                            , {1}.obj-code
                                                            , string({1}.fact-date, "99/99/9999")
                                                            )
                                          , input tot-lns
                                          , input '':U
                                          , input '':U
                                          , input (p-table-name + {&delim-key} + {1}.doc-code)
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
                                        , input p-table-name
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-client Dialog-Frame
FUNCTION get-client RETURNS CHARACTER
  ( input loc-doc-code as character,
    input loc-doc-type as character) :
  case loc-doc-type:
    when {&overvalue} then do:
    assign
    dcli-type = ""
    dcli-code = ?
    dcli-name = "Переоценка"
    .
    find first ub.price-doc no-lock where
               ub.price-doc.doc-num = {1}.doc-code No-ERROR.
    if avail ub.price-doc then
    ddoc-ps = ub.price-doc.PS.
    else ddoc-ps = "".
    return dcli-type.
  end.
    when {&manufacturing}  then do:
      assign
      dcli-type = ""
      dcli-code = ?
      dcli-name = "Производство"
      .
      find first ub.fbr-doc no-lock where
                ub.fbr-doc.doc-code = {1}.doc-code No-ERROR.
      if avail ub.fbr-doc then
      ddoc-ps = ub.fbr-doc.PS.
      else ddoc-ps = "".
      return dcli-type.
    end.
    otherwise do:
      if lookup(loc-doc-type, {&order-type-all}) > 0 then do:
        FIND FIRST ub.ord-doc No-LOCK WHERE
                  ub.ord-doc.doc-code = loc-doc-code No-ERROR.
        if not avail ub.ord-doc then do:
          assign
          dcli-type = "?"
          dcli-code = ?
          dcli-name = "Заказ/заявка не найдены"
          ddoc-ps = ""
          .

          return dcli-type.
        end.
        assign
        dcli-type = ub.ord-doc.cli-type
        dcli-code = ub.ord-doc.cli-code
        ddoc-ps = ub.ord-doc.PS
        .
        find first ub.clients no-lock where
                  ub.clients.obj-type = ub.ord-doc.cli-type AND
                  ub.clients.obj-code = ub.ord-doc.cli-code No-ERROR.
        if not avail ub.clients then do:
            assign
            dcli-name = "Контрагент по заказу/заявке не найден"
            .
            return dcli-type.
        end.
        assign
        dcli-name = ub.clients.obj-name
        .

        return dcli-type.
      end.
      else do:
        if loc-doc-type begins "-" then do:
          FIND FIRST ub.c-trn-doc No-LOCK WHERE
                    ub.c-trn-doc.doc-code = loc-doc-code No-ERROR.
          if not avail ub.c-trn-doc then do:
            assign
            dcli-type = "?"
            dcli-code = ?
            dcli-name = "Документ не найден"
            ddoc-ps = ""
            .
            return dcli-type.
          end.
          assign
          dcli-type = ub.c-trn-doc.cli-type
          dcli-code = ub.c-trn-doc.cli-code
          ddoc-ps = ub.c-trn-doc.PS
          .
          find first ub.clients no-lock where
                    ub.clients.obj-type = ub.c-trn-doc.cli-type AND
                    ub.clients.obj-code = ub.c-trn-doc.cli-code No-ERROR.
          if not avail ub.clients then do:
            assign
            dcli-name = "Контрагент по документу не найден"
            .
            return dcli-type.
          end.
          assign
          dcli-name = ub.clients.obj-name
          .
          return dcli-type.

        end.
        else do:
      FIND FIRST ub.trn-doc No-LOCK WHERE
                ub.trn-doc.doc-code = loc-doc-code No-ERROR.
          if not avail ub.trn-doc then do:
        assign
        dcli-type = "?"
        dcli-code = ?
        dcli-name = "Документ не найден"
        ddoc-ps = ""
        .

        return dcli-type.
    end.
    assign
    dcli-type = ub.trn-doc.cli-type
    dcli-code = ub.trn-doc.cli-code
    ddoc-ps = ub.trn-doc.PS
    .
    find first ub.clients no-lock where
               ub.clients.obj-type = ub.trn-doc.cli-type AND
               ub.clients.obj-code = ub.trn-doc.cli-code No-ERROR.
    if not avail ub.clients then do:
        assign
        dcli-name = "Контрагент по документу не найден"
        .
        return dcli-type.
    end.
    assign
    dcli-name = ub.clients.obj-name
    .

    return dcli-type.
  end.
    end. /*else do:*/
  end. /*otherwise*/
end case.
  RETURN "".   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME