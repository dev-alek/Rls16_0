&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER buf-OR_ord-doc FOR ub.ord-doc.
DEFINE BUFFER buf-OR_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER buf-OR_trn-doc FOR ub.trn-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список заказов О-RC

Автор: Чернова Светлана Александровна
Дата создания: 04/03/06
Author: Svetlana Chernova
Creation date: 04/03/06

*/
/*
         ! ! !  В Н И М А Н И Е  ! ! !
   не забудь: после исправления файла в UIB

   САМОЕ ГЛАВНОЕ - подставить new shared в    DEFINE QUERY br-docs !!!!!!!
*/

define input parameter parparentproc  as widget-handle no-undo.
define input parameter bttns         as character   no-undo .
define input parameter par-mode      as character   no-undo .
define input parameter pardoc-rec    as recid no-undo.
define input parameter par-host-code like ub.clients.obj-code no-undo.
define input parameter p-obj-code    like ub.clients.obj-code no-undo.
define input parameter p-obj-type    like ub.clients.obj-type no-undo.
define input parameter p-doc-type    as character no-undo .
define input parameter p-status_     as character no-undo .
define input parameter p-char        as character no-undo .
define output parameter  rid-list         as  character no-undo . /* список recid'ов выбранных */


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список заказов ОРЦ ".
{ cmp/vssrevis.i }
/*кнопки для нажатия*/
define buffer buf_clients for ub.clients.
/*
message bttns
        par-mode
        pardoc-rec
        par-host-code
        p-obj-code
        p-obj-type
        p-doc-type
        p-status_
        p-char
        .
  */
/* Local Variable Definitions ---                                       */
define variable p-mark as character no-undo .
define variable g-log as logical no-undo .
define variable v-doc-rec as recid no-undo .
define variable sch-field as character no-undo.
define VARIABLE next-prev    as logical   no-undo .
define variable doc-rec    as recid no-undo .
define variable c-ps as character no-undo .

{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ cmp/df-sub.i }
{ cmp/gds-list.i gds-list def "new shared"}
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }


function f-nameo returns character ( par1 as recid ) :
define buffer fl for ub.ord-doc.
define buffer buf_obj for ub.clients.

find first fl no-lock where recid(fl) = par1 no-error .
find first buf_obj no-lock where
           buf_obj.obj-code = fl.obj-code and
           buf_obj.obj-type = fl.obj-type
           no-error .
if error-status :error then return "" .
return buf_obj.obj-name.

end function.



define buffer buf_sysconf for ub.sysconf  .
find first buf_sysconf where buf_sysconf.host-code = par-host-code no-lock.
define variable v-cntxt-cash-pay as integer   no-undo .
define variable v-cntxt-in-ov as logical   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
define variable v-cntxt-rsrv-time  as integer   no-undo .
define variable v-cntxt-load-time  as integer   no-undo .
define variable v-cntxt-holidays  as character no-undo .
define variable g#log as logical   no-undo .
assign
  v-cntxt-cash-pay   = buf_sysconf.cash-pay
  v-cntxt-base-code  = buf_sysconf.base-code
  v-cntxt-in-ov      = buf_sysconf.in-ov
  v-cntxt-rsrv-time  = buf_sysconf.rsrv-time
  v-cntxt-load-time  = buf_sysconf.load-time
  v-cntxt-holidays   = buf_sysconf.holidays
.


&glob order-type-gbd 2
&glob order-type-ubd 3


&scop ver-paket ~
  if num-entries(rid-list) = 0  then do: ~
  message "Не отмечено ни одной записи !!!" . ~
  return .                                    ~
  end.                                         ~
  message "Запускать пакетный режим обработки для " num-entries(rid-list) "записей ?" ~
           view-as alert-box question                                                  ~
           buttons yes-no                                                              ~
           update g-ok                                                                 ~
           .                                                                           ~
  if g-ok = false then return.



define variable filter-point as character no-undo init "Список заказов ОРЦ" .
define variable filter-point0 as character no-undo init "Заказы ОРЦ" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .




define variable br-handle as handle  no-undo .
DEFINE new SHARED VARIABLE Sort-gr AS LOGICAL
     LABEL "Сортировать по группам товаров"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO init false .

DEFINE new Shared VARIABLE print-graft AS LOGICAL
     LABEL "Отладочная печать"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO init true .


&scop col-l1  '*'
&scop col-l2  'Статус'
&scop col-l3  'OK'
&scop col-l4  '№ док-та'
&scop col-l5  'Создан'
&scop col-l6  'Факт'
&scop col-l7  'Объект'
&scop col-l8  'Тип'
&scop col-l9  'РЦ'
&scop col-l10 'Количество'
&scop col-l12 '>'
&scop col-l13 'Наименование'


&scop cop-l1   mark-string(recid( buf-OR_ord-doc), rid-list)
&scop dyn_cop-l1 substitute('dynamic-function(&1mark-string&1, recid(buf-or_ord-doc), &1&2&1)', ~{&double-quote~}, rid-list)
&scop cop-l2   buf-OR_ord-doc.status_
&scop cop-l3   buf-OR_ord-doc.flag_
&scop cop-l4   buf-OR_ord-doc.doc-code
&scop cop-l5   buf-OR_ord-doc.doc-date
&scop cop-l6   buf-OR_ord-doc.fact-date
&scop cop-l7   buf-OR_ord-doc.obj-code
&scop cop-l8   buf-OR_ord-doc.obj-type
&scop cop-l9   buf-OR_ord-doc.cli-type + string (buf-OR_ord-doc.cli-code)
&scop cop-l10  buf-OR_ord-doc.qnty
&scop cop-l12      f-direct(recid( buf-OR_ord-doc))
&scop dyn_cop-l12  substitute('dynamic-function(&1f-direct&1, recid(buf-or_ord-doc))', ~{&double-quote~})

&scop cop-l13      f-nameo(recid(buf-OR_ord-doc))
&scop dyn_cop-l13  substitute('dynamic-function(&1f-nameo&1, recid(buf-or_ord-doc))', ~{&double-quote~})

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf-OR_ord-doc buf-OR_ord-doc-rcv ord-chain ~
buf-OR_trn-doc

/* Definitions for BROWSE br-docs                                       */
&Scoped-define FIELDS-IN-QUERY-br-docs {&cop-l1} {&cop-l2} {&cop-l3} {&cop-l4} {&cop-l5} {&cop-l6} {&cop-l7} {&cop-l8} {&cop-l9} {&cop-l10} if trim (buf-OR_ord-doc.ps) <> "" then "+" else "" @ c-ps {&cop-l13}
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-docs {&cop-l2}
&Scoped-define SELF-NAME br-docs
&Scoped-define QUERY-STRING-br-docs FOR EACH buf-OR_ord-doc NO-LOCK
&Scoped-define OPEN-QUERY-br-docs OPEN QUERY {&SELF-NAME} FOR EACH buf-OR_ord-doc NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-docs buf-OR_ord-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-docs buf-OR_ord-doc


/* Definitions for BROWSE br-zapr                                       */
&Scoped-define FIELDS-IN-QUERY-br-zapr buf-OR_trn-doc.doc-code buf-OR_trn-doc.doc-type buf-OR_trn-doc.status_ buf-OR_trn-doc.flag_ buf-OR_trn-doc.cli-type + string(buf-OR_trn-doc.cli-code) buf-OR_trn-doc.obj-type + string(buf-OR_trn-doc.obj-code) buf-OR_trn-doc.doc-date buf-OR_trn-doc.fact-date buf-OR_trn-doc.tot-lines buf-OR_trn-doc.fact-qnty buf-OR_trn-doc.tot-rubl buf-OR_trn-doc.contract-code /* buf-OR_trn-doc.out-code */
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-zapr
&Scoped-define SELF-NAME br-zapr
&Scoped-define QUERY-STRING-br-zapr FOR EACH buf-OR_ord-doc-rcv WHERE                   buf-OR_ord-doc-rcv.doc-code = buf-OR_ord-doc.doc-code NO-LOCK, ~
        each ub.ord-chain no-lock where             ub.ord-chain.doc-code = buf-OR_ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and             ub.ord-chain.rel-doc-type = 'trn'          , ~
         EACH buf-OR_trn-doc  where        buf-OR_trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK
&Scoped-define OPEN-QUERY-br-zapr OPEN QUERY br-zapr FOR EACH buf-OR_ord-doc-rcv WHERE                   buf-OR_ord-doc-rcv.doc-code = buf-OR_ord-doc.doc-code NO-LOCK, ~
        each ub.ord-chain no-lock where             ub.ord-chain.doc-code = buf-OR_ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and             ub.ord-chain.rel-doc-type = 'trn'          , ~
         EACH buf-OR_trn-doc  where        buf-OR_trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-zapr buf-OR_ord-doc-rcv ub.ord-chain ~
buf-OR_trn-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-zapr buf-OR_ord-doc-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-br-zapr ub.ord-chain
&Scoped-define THIRD-TABLE-IN-QUERY-br-zapr buf-OR_trn-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-docs}~
    ~{&OPEN-QUERY-br-zapr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sel b-rep b-close b-PS b-sch ~
b-print b-hist b-help b-mark b-add b-lkp b-chg b-del b-open sch-code sch-date ~
sch-fact br-docs loc-ps B-lkp-2 br-zapr sch-num loc-boss loc-agnt loc-wrkr ~
loc-creid
&Scoped-Define DISPLAYED-OBJECTS sch-code sch-date sch-fact loc-ps sch-num ~
loc-boss loc-agnt loc-wrkr loc-creid

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-direct Dialog-Frame
FUNCTION f-direct RETURNS CHARACTER
( par1 as recid ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 9 BY 1 TOOLTIP "Добавить новый заказ".

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 12 BY 1 TOOLTIP "Корректировка заказа".

DEFINE BUTTON b-close
     LABEL "&Закрыть":L
     SIZE 12 BY 1 TOOLTIP "Закрыть заказ".

DEFINE BUTTON B-close-trn
     LABEL "Закр&ыть"
     SIZE 10 BY 1 TOOLTIP "Закрыть накладную".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 12 BY 1 TOOLTIP "Удалитиь заказ".

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 2.88 BY 1.

DEFINE BUTTON b-hist
     LABEL "Ис&тория":L
     SIZE 2.88 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 12 BY 1 TOOLTIP "Просмотр заказа без корректировки".

DEFINE BUTTON B-lkp-2
     LABEL "Просмо&тр"
     SIZE 10 BY 1 TOOLTIP "Просмотр накладной".

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.

DEFINE BUTTON b-open
     LABEL "&Открыть":L
     SIZE 12 BY 1 TOOLTIP "Открыть запр+ до запр-".

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 3 BY 1 TOOLTIP "Печать заказа".

DEFINE BUTTON b-PS
     LABEL "&Примечание":L
     SIZE 12 BY 1 TOOLTIP "Просмотр Примечания по заказу".

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 12 BY 1 TOOLTIP "Выход из режима".

DEFINE BUTTON b-reject
     LABEL "От&казать":L
     SIZE 12 BY 1 TOOLTIP "Проставить на заказ статус <<Отказать>>".

DEFINE BUTTON b-rep
     LABEL "О&тчеты":L
     SIZE 12 BY 1 TOOLTIP "Список отчетов по заказам".

DEFINE BUTTON B-rez
     LABEL "Накл"
     SIZE 10 BY 1 TOOLTIP "Создать расходную накладную для РЦ ".

DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     SIZE 3 BY 1 TOOLTIP "Фильтр по списку заказов".

DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     SIZE 12 BY 1 TOOLTIP "Выход из режима и выбор текущего номера  заказа".

DEFINE VARIABLE loc-ps AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 94.5 BY 1.75 TOOLTIP "Примечание"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc-agnt AS CHARACTER FORMAT "X(256)":U
     LABEL "Исп"
      VIEW-AS TEXT
     SIZE 17.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc-boss AS CHARACTER FORMAT "X(256)":U
     LABEL "М-р"
      VIEW-AS TEXT
     SIZE 17.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc-creid AS CHARACTER FORMAT "X(256)":U
     LABEL "Создал"
      VIEW-AS TEXT
     SIZE 15.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc-wrkr AS CHARACTER FORMAT "X(256)":U
     LABEL "Кл-к"
      VIEW-AS TEXT
     SIZE 17.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "x(12)"
     LABEL "&Начало номера"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999"
     LABEL "Д&ата"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE sch-fact AS DATE FORMAT "99/99/9999"
     LABEL "Фа&кт"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE sch-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE new shared QUERY br-docs FOR
      buf-OR_ord-doc SCROLLING.


DEFINE QUERY br-zapr FOR
      buf-OR_ord-doc-rcv,
      ub.ord-chain,
      buf-OR_trn-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-docs Dialog-Frame _FREEFORM
  QUERY br-docs NO-LOCK DISPLAY
      {&cop-l1}  COLUMN-LABEL {&col-l1} FORMAT "X(1)"
      {&cop-l2}  COLUMN-LABEL {&col-l2} Format "X(6)"
      {&cop-l3}  COLUMN-LABEL {&col-l3} format "+/-"
      {&cop-l4}  COLUMN-LABEL {&col-l4}
      {&cop-l5}  COLUMN-LABEL {&col-l5} FORMAT "99/99/99"
      {&cop-l6}  COLUMN-LABEL {&col-l6} FORMAT "99/99/99"
      {&cop-l7}  COLUMN-LABEL {&col-l7} format ">>>>9"
      {&cop-l8}  COLUMN-LABEL {&col-l8} format "x(3)"
      {&cop-l9}  COLUMN-LABEL {&col-l9}
      {&cop-l10} COLUMN-LABEL {&col-l10}
      if trim (buf-OR_ord-doc.ps) <> "" then "+" else "" @ c-ps  COLUMN-LABEL "П" format "x(1)"
      {&cop-l13} COLUMN-LABEL {&col-l13} Format "X(26)"
  ENABLE
       {&cop-l2}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.38 BY 9.83
         BGCOLOR 15 .

DEFINE BROWSE br-zapr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-zapr Dialog-Frame _FREEFORM
  QUERY br-zapr NO-LOCK DISPLAY
      buf-OR_trn-doc.doc-code
      buf-OR_trn-doc.doc-type FORMAT "X(3)"
      buf-OR_trn-doc.status_ COLUMN-LABEL "Стат" FORMAT "X(4)"
      buf-OR_trn-doc.flag_ COLUMN-LABEL "Ок" FORMAT "+/-"
      buf-OR_trn-doc.cli-type + string(buf-OR_trn-doc.cli-code)  COLUMN-LABEL "Контрагент"
      buf-OR_trn-doc.obj-type + string(buf-OR_trn-doc.obj-code)  COLUMN-LABEL "Объект"
      buf-OR_trn-doc.doc-date
      buf-OR_trn-doc.fact-date
      buf-OR_trn-doc.tot-lines
      buf-OR_trn-doc.fact-qnty COLUMN-LABEL "Количество" FORMAT ">>>>>>>>9.<<<"
      buf-OR_trn-doc.tot-rubl  COLUMN-LABEL "Сумма {&abbr_rub}." FORMAT ">>>>>>>>>9.99"
      buf-OR_trn-doc.contract-code COLUMN-LABEL "Вн.№ дог."
      /* buf-OR_trn-doc.out-code */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 94.75 BY 5.71.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 2
     b-sel AT ROW 1 COL 14
     b-rep AT ROW 1 COL 26
     b-close AT ROW 1 COL 38
     b-PS AT ROW 1 COL 50 WIDGET-ID 2
     b-reject AT ROW 1 COL 62 WIDGET-ID 6
     b-sch AT ROW 1 COL 84.5
     b-print AT ROW 1 COL 87.5
     b-hist AT ROW 1 COL 90.5
     b-help AT ROW 1 COL 93.5
     b-mark AT ROW 2 COL 2
     b-add AT ROW 2 COL 5
     b-lkp AT ROW 2 COL 14
     b-chg AT ROW 2 COL 26
     b-del AT ROW 2 COL 38
     b-open AT ROW 2 COL 50
     sch-code AT ROW 3.08 COL 26 COLON-ALIGNED
     sch-date AT ROW 3.08 COL 47 COLON-ALIGNED
     sch-fact AT ROW 3.08 COL 65.75 COLON-ALIGNED
     br-docs AT ROW 4.21 COL 1
     loc-ps AT ROW 15.08 COL 1.5 NO-LABEL WIDGET-ID 4
     B-rez AT ROW 16.92 COL 1
     B-lkp-2 AT ROW 16.92 COL 11
     B-close-trn AT ROW 16.92 COL 21
     br-zapr AT ROW 18 COL 1.5
     sch-num AT ROW 3.25 COL 80.38 COLON-ALIGNED NO-LABEL
     loc-boss AT ROW 14.25 COL 4.63 COLON-ALIGNED
     loc-agnt AT ROW 14.25 COL 27.88 COLON-ALIGNED
     loc-wrkr AT ROW 14.25 COL 53 COLON-ALIGNED
     loc-creid AT ROW 14.25 COL 78.75 COLON-ALIGNED
     " Поиск по:" VIEW-AS TEXT
          SIZE 10.13 BY .67 AT ROW 3.25 COL 1.63
          BGCOLOR 3 FGCOLOR 15
     SPACE(84.62) SKIP(19.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список заказов ОРЦ".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf-OR_ord-doc B "NEW SHARED" ? ub ord-doc
      TABLE: buf-OR_ord-doc-rcv B "?" ? ub ord-doc-rcv
      TABLE: buf-OR_trn-doc B "?" ? ub trn-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-docs sch-fact Dialog-Frame */
/* BROWSE-TAB br-zapr B-close-trn Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-close-trn IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-close-trn:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-rez IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-rez:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       br-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

ASSIGN
       loc-ps:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-docs
/* Query rebuild information for BROWSE br-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf-OR_ord-doc NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE new shared QUERY br-docs FOR
      buf-OR_ord-doc SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE br-docs */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-zapr
/* Query rebuild information for BROWSE br-zapr
     _START_FREEFORM
OPEN QUERY br-zapr FOR EACH buf-OR_ord-doc-rcv WHERE
                  buf-OR_ord-doc-rcv.doc-code = buf-OR_ord-doc.doc-code NO-LOCK,
 each ub.ord-chain no-lock where
            ub.ord-chain.doc-code = buf-OR_ord-doc-rcv.rcv-code and
            ub.ord-chain.doc-type = 'rcv'                  and
            ub.ord-chain.rel-doc-type = 'trn'          ,
  EACH buf-OR_trn-doc  where
       buf-OR_trn-doc.doc-code = ub.ord-chain.rel-doc-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "buf-OR_ord-doc-rcv.doc-code = buf-OR_ord-doc.doc-code"
     _JoinCode[2]      = "buf-OR_ord-doc-rcv.doc-code = buf-OR_ord-doc.doc-code"
     _Query            is OPENED
*/  /* BROWSE br-zapr */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список заказов ОРЦ */
DO:
  delete widget-pool "my-pool" no-error  .
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-add in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
do on stop undo, return no-apply :
  find current buf-OR_ord-doc exclusive-lock no-error .  /* сетевая проверка */
end.

define variable rr as recid no-undo .
define buffer buf_clients for ub.clients.
define buffer obj_clients for ub.clients.
define variable aobj-type as character no-undo .
define variable aobj-code as integer   no-undo .

 if not available buf-or_ord-doc then return.


   if not (
   ( buf-OR_ord-doc.status_ = {&g___new} and buf-OR_ord-doc.flag_ = false ) or
   ( buf-OR_ord-doc.status_ = {&ord-req} and buf-OR_ord-doc.flag_ = true  )
   ) then do:
      message "Нельзя корректировать заказ! " view-as alert-box  .
      return.
  end.

  aobj-type  = buf-OR_ord-doc.obj-type .
  aobj-code  = buf-OR_ord-doc.obj-code .

if buf-OR_ord-doc.status_ = {&ord-req} then do:
      find first buf_clients no-lock where
                buf_clients.obj-code = buf-OR_ord-doc.cli-code and
                buf_clients.obj-type = buf-OR_ord-doc.cli-type
                no-error .
  aobj-type  = buf-OR_ord-doc.cli-type .
  aobj-code  = buf-OR_ord-doc.cli-code .

      find first obj_clients no-lock where
                obj_clients.obj-code = buf-OR_ord-doc.obj-code and
                obj_clients.obj-type = buf-OR_ord-doc.obj-type
                no-error .

      if buf_clients.db-num <> v-cntxt-db-num then do:
          message "Корректировать возможно только в БД:"  buf_clients.db-num view-as alert-box error .
          return .
      end.

      if  p-obj-code = buf-OR_ord-doc.obj-code and
          p-obj-type = buf-OR_ord-doc.obj-type then do:
        message "Корректирование в этом статусе возможно на объекте: "
            buf-OR_ord-doc.cli-code
            buf-OR_ord-doc.cli-type
            view-as alert-box error .
            return .
      end.
end.

  if   buf-OR_ord-doc.status_ = {&g___new}  and
        not (p-obj-code = buf-OR_ord-doc.obj-code and
             p-obj-type = buf-OR_ord-doc.obj-type ) then do:
    message "Корректирование в этом статусе возможно на объекте: "
        buf-OR_ord-doc.obj-code
        buf-OR_ord-doc.obj-type
        view-as alert-box error .
        return .
  end.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_o-r_update':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    p-obj-type
    p-obj-code
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .

  rr = recid(buf-or_ord-doc) .
  run cus/ord-oru.w
    ( input parparentproc,
      input-output rr ,
      input {&update} ,
 input-output br-handle ,
 input-output next-prev

      ) .
  v-doc-rec = rr .
  g#log =  {&browse-name}:refresh() .
  apply "value-changed" to br-docs in frame dialog-frame.
  apply "entry" to br-docs in frame dialog-frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-close Dialog-Frame
ON CHOOSE OF b-close IN FRAME Dialog-Frame /* Закрыть */
DO:

define variable rr as recid no-undo .
  if not available buf-or_ord-doc then return.
  rr = recid(buf-or_ord-doc) .

    if buf-or_ord-doc.status_ <> {&g___new}  then do:
      /*
        message "Переход в другие статусы проходит автоматически" .
        return .
        */
    end.

  run ord-close in this-procedure (recid(buf-or_ord-doc)) .
  run openbr in this-procedure (yes, no, '':u).
  reposition {&browse-name} to recid rr no-error.
  apply "value-changed" to br-docs in frame dialog-frame.
  apply "entry" to br-docs in frame dialog-frame.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-close-trn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-close-trn Dialog-Frame
ON CHOOSE OF B-close-trn IN FRAME Dialog-Frame /* Закрыть */
DO:
    /*закроем ЗАПР  */

 if not available buf-OR_trn-doc   then return.

 message "Закрыть накладную ?"
  view-as alert-box question
  buttons yes-no
  update g-log.
  if g-log = false then return no-apply.

    run close-zapr in this-procedure ( input buf-OR_trn-doc.doc-code ) .
   {&OPEN-QUERY-br-zapr}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  if not available buf-OR_ord-doc then return.

do on stop undo, return no-apply :
  find current buf-OR_ord-doc exclusive-lock .  /* сетевая проверка */
end.

  if not( buf-OR_ord-doc.status_ = {&g___new} and buf-OR_ord-doc.flag_ = false ) then do:
      /* удалить заказ  ЗАПР+ с активной стороны */
    if buf-OR_ord-doc.cli-code = p-obj-code and
       buf-OR_ord-doc.cli-type = p-obj-type and
       buf-OR_ord-doc.status_  = {&ord-req}
       then do:
          run ord-del (recid(buf-OR_ord-doc)) .
          return .
    end.

    message "Нельзя удалять заказ ! " view-as alert-box  .
    return .
  end.

  if   not (p-obj-code = buf-OR_ord-doc.obj-code and
            p-obj-type = buf-OR_ord-doc.obj-type ) then do:
    message "Удалить этом статусе возможно на объекте: "
        buf-OR_ord-doc.obj-code
        buf-OR_ord-doc.obj-type
        view-as alert-box error .
        return .
  end.

  run ord-del in this-procedure ( recid ( buf-OR_ord-doc ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
if not available buf-OR_ord-doc then return .
    run cus/ordcdoc.w
    (
    parParentProc,
    buf-OR_ord-doc.host-code,
    buf-OR_ord-doc.doc-code,
    "" ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
 if not available buf-OR_ord-doc then return .

 define variable rr as recid no-undo .
 rr = recid(buf-OR_ord-doc) .
      br-handle = {&browse-name}:handle in frame {&frame-name} .
      next-prev = no.
      do while next-prev <> ?:
        if not available buf-OR_ord-doc then do:
          message "Неправильный выбор документа.".
          return no-apply.
        end.
          run cus/ord-oru.w
             ( input parparentproc,
               input-output rr ,
               input {&lookup} ,
               input-output br-handle ,
               input-output next-prev
               ).
          v-doc-rec = rr .

        if br-handle = ? then reposition {&browse-name} to recid rr no-error.
      end.
apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp-2 Dialog-Frame
ON CHOOSE OF B-lkp-2 IN FRAME Dialog-Frame /* Просмотр */
DO:
   if not available buf-or_trn-doc then return .
      run str/showdoc.p
          (input parparentproc
          ,input buf-or_trn-doc.doc-code
          ,input ""
          ,input ""
          ,input 0
          ,input true
          ) no-error .
          if error-status :error then message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "Ошибка из showdoc.p"
            view-as alert-box error
          .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
        if available buf-OR_ord-doc then do:
        { gbl/markstrn.i buf-OR_ord-doc rid-list }

        g-log = br-docs:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = br-docs:select-next-row ().
            apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
        end.
    end.
    apply "entry" to br-docs in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-open
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-open Dialog-Frame
ON CHOOSE OF b-open IN FRAME Dialog-Frame /* Открыть */
DO:
  define variable rr as recid no-undo .
  if not available buf-OR_ord-doc then return.
  rr = recid(buf-OR_ord-doc) .
  run ord-open in this-procedure (recid(buf-OR_ord-doc)) .
  run openbr in this-procedure (yes, no, '':u).
  reposition {&browse-name} to recid rr no-error.
  apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
  apply "entry" TO BR-docs IN FRAME Dialog-Frame.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:

  find current buf-OR_ord-doc no-lock no-error .
  if available buf-OR_ord-doc then
      run cus/torg-26.p
        ( input parParentProc ,
          recid (buf-or_ord-doc) ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-PS
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-PS Dialog-Frame
ON CHOOSE OF b-PS IN FRAME Dialog-Frame /* Примечание */
DO:
 if not available buf-OR_ord-doc then return .
 define variable notes as character no-undo.
    notes = buf-OR_ord-doc.ps .
    run gbl/notes.w ( input {&lookup} , input-output notes).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-reject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-reject Dialog-Frame
ON CHOOSE OF b-reject IN FRAME Dialog-Frame /* Отказать */
DO:

define variable rr as recid no-undo .
  if not available buf-or_ord-doc then return.

    rr = recid(buf-or_ord-doc) .

    if buf-or_ord-doc.status_ <> {&ord-req} then do:
       message "Отказать можно в статусе ЗАПРОС !" view-as alert-box  .
       return .
    end.

 message "Вы действительно хотите поставить статус ОТКАЗАТЬ на заказ ?"
   view-as alert-box question
  buttons yes-no
  update g-log.
  if g-log = false then return .

  find current buf-or_ord-doc exclusive-lock no-error .
  if available buf-or_ord-doc then do:
     buf-or_ord-doc.status_ =  {&ord-rejection} .
  end.

  run openbr in this-procedure (yes, no, '':u).
  reposition {&browse-name} to recid rr no-error.
  apply "value-changed" to br-docs in frame dialog-frame.
  apply "entry" to br-docs in frame dialog-frame.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rep Dialog-Frame
ON CHOOSE OF b-rep IN FRAME Dialog-Frame /* Отчеты */
DO:
  run gbl/pop-up.p ( self:handle, no) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-rez
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-rez Dialog-Frame
ON CHOOSE OF B-rez IN FRAME Dialog-Frame /* Накл */
DO:
if not available buf-OR_ord-doc then return .
do transaction :
  find current buf-OR_ord-doc exclusive-lock .  /* сетевая проверка */
  if not available buf-OR_ord-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "3"
      view-as alert-box error
    .
    return .
end.
g#log =  {&BROWSE-NAME}:refresh() .
define variable v-ok  as logical   no-undo .
define buffer buf_clients for ub.clients.
define buffer obj_clients for ub.clients.

if not available buf-OR_ord-doc then return .

if buf-OR_ord-doc.status_ <> {&ord-req} then  do:
    message "Создание накладной невозможно в этом статусе !" view-as alert-box error .
    return .
end.

find first buf_clients no-lock where
           buf_clients.obj-code = buf-OR_ord-doc.cli-code and
           buf_clients.obj-type = buf-OR_ord-doc.cli-type
           no-error .

find first obj_clients no-lock where
           obj_clients.obj-code = buf-OR_ord-doc.obj-code and
           obj_clients.obj-type = buf-OR_ord-doc.obj-type
           no-error .

 if buf_clients.db-num <> v-cntxt-db-num then do:
    message "Создание накладной возможно только в БД:"  buf_clients.db-num view-as alert-box error .
    return .
 end.

 if p-obj-code = buf-OR_ord-doc.obj-code and
    p-obj-type = buf-OR_ord-doc.obj-type then do:
  message "Создание накладной возможно на объекте: "
      buf-OR_ord-doc.cli-code
      buf-OR_ord-doc.cli-type
      view-as alert-box error .
      return .
 end.

 if obj_clients.host-code <> buf_clients.host-code then do:
        message "Создавать накладную межфирменного перемещения ?"
        view-as alert-box question
        buttons yes-no
        update v-ok
        .
        if v-ok  = false then return .
        run cus/crhldr.p
          ( input parparentproc ,
            input buf-OR_ord-doc.doc-code ) no-error .
        if error-status :error then
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "ошибка из crhldr.p"
          view-as alert-box error
        .


     end.
    else do:
        message "Создавать внутреннюю расходную накладную ?"
          view-as alert-box question
          buttons yes-no
          update v-ok
          .
        if v-ok  = false then return .
        run cus/crrasper.p
          ( input parparentproc ,
            input buf-OR_ord-doc.doc-code ) no-error .
        if error-status :error then
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "ошибка из crrasper.p"
          view-as alert-box error
        .
    end.
  end.
  g#log =  {&BROWSE-NAME}:refresh() .
  {&OPEN-QUERY-br-zapr}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор  */
DO:
    if ( available buf-OR_ord-doc ) AND ( rid-list = "" ) then
    rid-list = string( recid( buf-OR_ord-doc ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-docs
&Scoped-define SELF-NAME br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-docs Dialog-Frame
ON VALUE-CHANGED OF br-docs IN FRAME Dialog-Frame
DO:
 if not available buf-OR_ord-doc then return .
 define buffer buf_clients for ub.clients.

  { gbl/usrfulnm.i
    buf-OR_ord-doc.creid
    loc-creid
    }

 find first buf_clients no-lock where
         buf_clients.obj-type = {&prs}  and
         buf_clients.obj-code  = buf-OR_ord-doc.boss no-error.
    if available buf_clients then loc-boss = buf_clients.obj-name.
    else loc-boss = "".

 find first buf_clients no-lock where
         buf_clients.obj-type = {&prs}  and
         buf_clients.obj-code  = buf-OR_ord-doc.agnt no-error.
    if available buf_clients then loc-agnt = buf_clients.obj-name.
    else loc-agnt = "".

 find first buf_clients no-lock where
         buf_clients.obj-type = {&prs}  and
         buf_clients.obj-code  = buf-OR_ord-doc.wrkr no-error.
    if available buf_clients then loc-wrkr = buf_clients.obj-name.
    else loc-wrkr = "".

  loc-ps = trim(buf-OR_ord-doc.PS) .
  display loc-creid
    loc-boss
    loc-agnt
    loc-wrkr
    loc-ps
  with frame {&frame-name}.

  {&OPEN-QUERY-br-zapr}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON return OF sch-code IN FRAME Dialog-Frame /* Начало номера */
DO:
  run proc-sch-code in this-procedure(no, input frame {&frame-name} sch-code) no-error.
  return no-apply.
END.

ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-sch-code in this-procedure(yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON return OF sch-date IN FRAME Dialog-Frame /* Дата */
DO:
  run proc-sch-date in this-procedure(no, input frame {&frame-name} sch-date) no-error.
  return no-apply.
END.

ON CTRL-J OF sch-date IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-sch-date in this-procedure(yes, input frame {&frame-name} sch-date) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-fact
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-fact Dialog-Frame
ON return OF sch-fact IN FRAME Dialog-Frame /* Факт */
DO:
  run proc-sch-fact in this-procedure(no, input frame {&frame-name} sch-fact) no-error.
  return no-apply.
END.

ON CTRL-J OF sch-fact IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-sch-fact in this-procedure(yes, input frame {&frame-name} sch-fact) no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

define MENU m-rep
    .
assign b-rep:popup-menu in frame {&frame-name}  = menu m-rep:handle.
assign b-rep:menu-mouse   = 1.

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/setfltnm.i }

{ gbl/brwrepos.i
  &line-num=8
}
{ gbl/brwrefre.i "run OpenBr(yes, no, '':U)." }
{ gbl/ed_date.i sch-date }
{ gbl/ed_date.i sch-fact }

{ gbl/app_help.i  &disable_diasize_init=true &browse-name="BR-docs"}
{ gbl/mv-clmn.i
 &ext-col = 10
 &start-column = 5
 &frame-name = {&frame-name}
 &browse-name = {&browse-name}
}

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "buf-OR_ord-doc"
  &label-clmn_1     = "{&col-l1}"
  &label-clmn_2     = "{&col-l2}"
  &label-clmn_3     = "{&col-l3}"
  &label-clmn_4     = "{&col-l4}"
  &label-clmn_5     = "{&col-l5}"
  &label-clmn_6     = "{&col-l6}"
  &label-clmn_7     = "{&col-l7}"
  &label-clmn_8     = "{&col-l8}"
  &label-clmn_9     = "{&col-l9}"
  &label-clmn_10     = "{&col-l10}"
  &label-clmn_11     = "{&col-l12}"
  &label-clmn_12     = "{&col-l13}"
  &sort-clmn_1    =   "{&cop-l1}"
  &dyn_sort-clmn_1    = "{&dyn_cop-l1}"
  &sort-clmn_2    =   "{&cop-l2}"
  &sort-clmn_3    =   "{&cop-l3}"
  &sort-clmn_4    =   "{&cop-l4}"
  &sort-clmn_5    =   "{&cop-l5}"
  &sort-clmn_6    =   "{&cop-l6}"
  &sort-clmn_7    =   "{&cop-l7}"
  &sort-clmn_8    =   "{&cop-l8}"
  &sort-clmn_9    =   "{&cop-l9}"
  &sort-clmn_10    =   "{&cop-l10}"
  &sort-clmn_11    =   "{&cop-l12}"
  &dyn_sort-clmn_11    = "{&dyn_cop-l12}"
  &sort-clmn_12    =   "{&cop-l13}"
  &dyn_sort-clmn_12    = "{&dyn_cop-l13}"
&open-query     = "run OpenBr(yes, no, '':U)."
&open-query-otherwise = "run OpenBr(yes, no, '':U)."
&sort-column-name     = "sort-column-name"
&re-move-clmn         = "yes"
&mv-brw-default       = "yes" }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   {&cop-l2}:read-only in browse {&browse-name} = true .
   define buffer find_code for ub.ord-doc.
      if pardoc-rec <> ? then do:
      FIND FIRST find_code No-LOCK where
                 recid(find_code) = pardoc-rec No-ERROR.
      if not avail find_code then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова pardoc-rec" pardoc-rec
        view-as alert-box error .
        return error.
      end.
      doc-rec = pardoc-rec.
    end.
  run my-enable_ui in this-procedure .
  run openbr in this-procedure (yes, no, '':u).

  if pardoc-rec <> ? then
  reposition br-docs to recid doc-rec no-error.
  run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  browse br-zapr :handle
      ) .

  run diasize_init in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-docs.

END.
run disable_ui in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE close-zapr Dialog-Frame
PROCEDURE close-zapr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input parameter p-trn-code as character no-undo .


define buffer buf_s-trn-doc for ub.trn-doc.
define variable varmode            as   character           no-undo.
define variable varstatus          like ub.trn-doc.status_  no-undo.
define variable varflag            like ub.trn-doc.flag     no-undo.
define variable varcopystatus      like ub.trn-doc.status_  no-undo.
define variable varcopyflag        like ub.trn-doc.flag     no-undo.
define variable varcheck-return as logical no-undo .
define variable varchg-inv as logical no-undo .
assign
  varmode         = {&close-doc}
  varstatus       = {&g___new}
  varflag         = false
  varcopystatus   = {&g___new}
  varcopyflag     = true
  varcheck-return = true
  varchg-inv      = true
  .

run str/trn-graf.p
    (input  p-trn-code,
    input  v-cntxt-db-num,
    input  varmode,
    output varstatus,
    output varflag,
    output varcopystatus,
    output varcopyflag
  ) no-error.


if error-status:error then do:
   if error-status :get-message(1) <> "" or
      return-value = ""                  then do:
     message "Ошибка при вызове trn-graf.p." skip
     error-status :get-meSSAGE(1) skip
     return-value skip
     view-as alert-box error.
   end.
   else do:
     message return-value
     view-as alert-box error.
   end.
   return error.
end.

run str/trn-stat.p (
                input  parparentproc ,
                input this-procedure ,
                input  varmode,
                input  p-trn-code,
                input  varcheck-return,
                input  v-cntxt-db-num,
                input  v-cntxt-in-ov,
                input  v-cntxt-rsrv-time,
                input  v-cntxt-load-time,
                input  v-cntxt-holidays,
                input  yes,
                output varchg-inv,
                output table gds-list) no-error.
if error-status:error then do:
   message
     vss-workfile vss-revision vss-description skip
     "Ошибка при принудительном закрытии документа " p-trn-code skip
     return-value skip
     trim(error-status :get-message(1))
     trim(error-status :get-message(2))
     trim(error-status :get-message(3))
     trim(error-status :get-message(4))
     trim(error-status :get-message(5)) skip
     view-as alert-box error.
   return error.
end.


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
  DISPLAY sch-code sch-date sch-fact loc-ps sch-num loc-boss loc-agnt loc-wrkr
          loc-creid
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-sel b-rep b-close b-PS b-sch b-print b-hist b-help b-mark b-add
         b-lkp b-chg b-del b-open sch-code sch-date sch-fact br-docs loc-ps
         B-lkp-2 br-zapr sch-num loc-boss loc-agnt loc-wrkr loc-creid b-reject
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE main-ord Dialog-Frame
PROCEDURE main-ord :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input parameter   p-in-ord-num as character no-undo .
define output parameter  p-out-ord-num as character no-undo .

if num-entries(p-in-ord-num , "." ) = 1 then
   p-out-ord-num = p-in-ord-num .
   else do:
     p-out-ord-num = entry(1, entry( 1 , p-in-ord-num , "." ) , "-" )  + "-" + entry( 2 , p-in-ord-num , "."  ) .
   end.


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable_UI Dialog-Frame
PROCEDURE my-enable_UI :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  DISPLAY
      sch-code
      sch-date
      sch-fact
      B-rez
      loc-ps
      WITH FRAME Dialog-Frame.
  ENABLE b-quit
         b-mark       when lookup("b-mark":U,  bttns) > 0
         b-sel        when lookup("b-sel":U,   bttns) > 0
         b-sch
         b-hist
         b-help
         b-add        when lookup("b-add":U,  bttns) > 0 and not ( par-mode begins "rc" )
         b-lkp
         b-lkp-2
         b-chg        when lookup("b-chg":U,  bttns) > 0
         b-del        when lookup("b-del":U,  bttns) > 0
         b-close
         b-reject     when par-mode begins "rc"
         b-open
         b-print
         sch-code
         sch-date
         sch-fact
         br-docs
         br-zapr
         B-rez
         b-rep
         b-PS
         loc-ps
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

  hide b-open in frame dialog-frame.

define variable  m-i-rc  as widget-handle.
define variable  m-i-rc2  as widget-handle.
create widget-pool "my-pool" persistent no-error .

if par-mode begins "rc"  then do:
create menu-item m-i-rc in widget-pool "my-pool"
  assign parent = menu m-rep:handle
  label = "Отчет о выполнении РЦ заказов на товары"
  .
on choose of m-i-rc persistent run run-rep (1) .
end.

create menu-item m-i-rc2 in widget-pool "my-pool"
  assign parent = menu m-rep:handle
  label = "Отчет по заказам на РЦ"
  .
on choose of m-i-rc2 persistent run run-rep (2) .



  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define variable p-file-label as character no-undo .

p-file-label = "Заказы Объект-РЦ".

title0 = caps(p-file-label) + {&space-char}.

{&SetCursorWait}
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

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH buf-OR_ord-doc

&scop flt-open-dyn_open-query  FOR EACH buf-or_ord-doc

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name buf-or_ord-doc


&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition


&scop flt-open-query p-open-query

&scop flt-open-table-name buf-OR_ord-doc

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-def define buffer buf-OR_ord-doc for ord-doc.

&scop flt-open-debug-file

define variable l-open-query as logical   no-undo .
find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .

if not available buf_clients then return .
filter-point = filter-point0 + par-mode.

  CASE par-mode :
    WHEN {&obj} THEN DO:
       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name
                                          + " Объект: " +  p-obj-type
                                          + "  " +   string (p-obj-code)
                                          .

      { gbl/fltopend.i
        &where-cond = " buf-OR_ord-doc.host-code = par-host-code and buf-OR_ord-doc.obj-code = p-obj-code and buf-OR_ord-doc.obj-type = p-obj-type and buf-OR_ord-doc.doc-type = p-doc-type "

     &dyn_where-cond =  " substitute(' buf-OR_ord-doc.host-code = &2 and ~
                        buf-OR_ord-doc.obj-code = &3  and               ~
                        buf-OR_ord-doc.obj-type = &1&4&1  and            ~
                        buf-OR_ord-doc.doc-type = &1&5&1' , ~{&double-quote~} , par-host-code , p-obj-code, p-obj-type , p-doc-type) "
        &use-ind    = " USE-INDEX by-obj "
        &by         = " " }
    END.

    WHEN "status":U THEN DO:
       ASSIGN frame {&frame-name}:TITLE = title0 + "  ФИРМА: " + buf_clients.obj-name
                                          + " Объект: " +  p-obj-type
                                          + "  " +   string (p-obj-code)
                                          + "   Статус: " +  string(p-status_) .
      { gbl/fltopend.i
        &where-cond = " buf-OR_ord-doc.host-code = par-host-code and buf-OR_ord-doc.obj-code = p-obj-code and buf-OR_ord-doc.obj-type = p-obj-type and buf-OR_ord-doc.doc-type = p-doc-type  and buf-OR_ord-doc.status_= p-status_ "
     &dyn_where-cond =  " substitute(' buf-OR_ord-doc.host-code = &2 and ~
                        buf-OR_ord-doc.obj-code = &3     and  ~
                        buf-OR_ord-doc.obj-type = &1&4&1 and  ~
                        buf-OR_ord-doc.doc-type = &1&5&1 and  ~
                        buf-OR_ord-doc.status_  = &1&6&1 ' , ~{&double-quote~} , par-host-code , p-obj-code, p-obj-type , p-doc-type , p-status_ ) "
        &use-ind    = " USE-INDEX by-obj-type "
        &by         = "  " }
    end.

    WHEN "rc":U + {&obj} THEN DO:
       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name
                                          + " РЦ: " +   p-obj-type
                                          + "  " +   string (p-obj-code)
                                          .

      { gbl/fltopend.i
        &where-cond = " buf-or_ord-doc.cons-code = chr(-1) and buf-or_ord-doc.cli-code = p-obj-code and buf-or_ord-doc.cli-type = p-obj-type and buf-or_ord-doc.doc-type = p-doc-type "
     &dyn_where-cond =  " substitute(' buf-OR_ord-doc.cons-code = chr(-1) and ~
                        buf-OR_ord-doc.cli-code = &2     and  ~
                        buf-OR_ord-doc.cli-type = &1&3&1 and  ~
                        buf-OR_ord-doc.doc-type = &1&4&1 ' , ~{&double-quote~} , p-obj-code, p-obj-type , p-doc-type ) "

        &use-ind    = " USE-INDEX by-cons-cli-doc "
        &by         = " by buf-or_ord-doc.doc-date desc by buf-or_ord-doc.fact-num desc " }
    END.

    WHEN "rc":U + "status":U THEN DO:
       ASSIGN frame {&frame-name}:TITLE = title0 + "  ФИРМА: " + buf_clients.obj-name
                                          + " РЦ: " +  p-obj-type
                                          + "  " +   string (p-obj-code)
                                          + "   Статус: " +  string(p-status_) .
      { gbl/fltopend.i
        &where-cond = " buf-or_ord-doc.cons-code = chr(-1) and buf-OR_ord-doc.cli-code = p-obj-code and buf-OR_ord-doc.cli-type = p-obj-type and buf-OR_ord-doc.doc-type = p-doc-type  and buf-OR_ord-doc.status_= p-status_ "
     &dyn_where-cond =  " substitute(' buf-OR_ord-doc.cons-code = chr(-1) and ~
                        buf-OR_ord-doc.cli-code = &2     and  ~
                        buf-OR_ord-doc.cli-type = &1&3&1 and  ~
                        buf-OR_ord-doc.doc-type = &1&4&1 and  ~
                        buf-OR_ord-doc.status_  = &1&5&1 ' , ~{&double-quote~} , p-obj-code, p-obj-type , p-doc-type , p-status_ ) "

        &use-ind    = " USE-INDEX by-cons-cli-doc "
        &by         = " by buf-or_ord-doc.doc-date desc by buf-or_ord-doc.fact-num desc " }

    END.


END CASE.
if not p-open-query then
  reposition br-docs to recid doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame  .
{&OPEN-QUERY-br-zapr}
{&SetCursorNo}

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ord-close Dialog-Frame
PROCEDURE ord-close :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input parameter p-loc-recid as recid no-undo .

if par-mode begins "rc" and
   buf-or_ord-doc.status_ = {&g___new}
    then do:
        message "Заказ в статусе Новый закрывается на стороне создания" view-as alert-box information .
        return.
    end.

message "Закрыть заказ ?"
view-as alert-box question
buttons yes-no
update g-log.
if g-log = false then return .

  run cus/ordorcls.p (parparentproc, p-loc-recid , true ) no-error .
  if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
            "Ошибка из ordorcls.p " skip
              skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error
             .
      return .
  end.
  else do:
    run openbr in this-procedure ( yes, no, '':u).
  end.
  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ord-del Dialog-Frame
PROCEDURE ord-del :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-loc-recid as recid no-undo .

find current buf-OR_ord-doc  exclusive-lock    no-error .
if not available buf-OR_ord-doc  then return .

define variable g-log as log no-undo.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_o-r_deletion':U
  {&cntxt-object}
  v-cntxt-host-code-obj
  p-obj-type
  p-obj-code
  0
  0
  0
  true
  g-log
}
if not g-log then  return .


if  buf-OR_ord-doc.status_ = {&fact}  then do:
    message "Заказ в статусе ФАКТ не может быть удален !!!"
    view-as alert-box information .
    return error .
end.


message "Удалить запись ?"
view-as alert-box question
buttons yes-no
update g-log.
if g-log = false then return no-apply.

delete buf-OR_ord-doc .
run openbr in this-procedure (yes, no, '':u).

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ord-open Dialog-Frame
PROCEDURE ord-open :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-loc-recid as recid no-undo .

message "Открыть заказ ?"
view-as alert-box question
buttons yes-no
update g-log.
if g-log = false then return no-apply.

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add Dialog-Frame
PROCEDURE proc-add :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_o-r_add-def':U
  {&cntxt-object}
  par-host-code
  p-obj-type
  p-obj-code
  0
  0
  0
  true
  g-log
}
if not g-log then  return .


define variable rr as recid no-undo .
  rr = ? .
  run cus/ord-oru.w
     (input parparentproc,
      input-output rr ,
      input {&add-def} ,
      input-output br-handle ,
      input-output next-prev
      ).
  v-doc-rec = rr .
  run openbr in this-procedure ( yes, no, '':u).
  reposition br-docs to recid v-doc-rec no-error .
  apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.



  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
assign
  tbl = 'ord-doc'
  join-tbl = 'buf-OR_ord-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code'                      , '№ заказа'  , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_'                       , 'Статус'    , 'order-status-all',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('flag_'                         , 'ОК'        , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date'                      , 'Дата док-та', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date'                     , 'Дата факт'  , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code'  , 'Контрагент' , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code'  , 'Объект'     , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('agnt'                          , 'Исполнитель', 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('boss'                          , 'Менеджер'   , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('wrkr'                          , 'Кладовщик'  , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('creid'                         , 'Создал'     , 'usr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code'                     , 'Фирма'      , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-code'                      , 'Код оплаты' , 'pay',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ship-date'                     , 'Дата отгрузки' , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS'                            , 'Примечание', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('contract-code'                  , 'Вн.№ договора', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('exch-code'                      , 'Валюта','curr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name'                      , 'Правил', 'usr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( input parparentproc, input filter-point, input tbl, input join-tbl, input fld, input lab, input spr, input dim ).
  run openbr in this-procedure (yes, no, '':u).
END. /* Filter-Block */



  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sch-code Dialog-Frame
PROCEDURE proc-sch-code :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input parameter par-next as logical no-undo.
define input parameter pardoc-code as character no-undo.
display "" @ sch-date with frame {&frame-name}.
display "" @ sch-fact with frame {&frame-name}.

assign
  pardoc-code = {&double-quote} + pardoc-code + {&double-quote} .

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and buf-OR_ord-doc.doc-code begins &1 "
      , pardoc-code)
    ) no-error .
    if error-status :error or return-value = ? then
       message "Не найдено ни одной записи !" view-as alert-box .

 apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.



  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sch-date Dialog-Frame
PROCEDURE proc-sch-date :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input parameter par-next as logical no-undo.
define input parameter pardoc-code as date no-undo.
define variable ppp as character no-undo .

display "" @ sch-fact with frame {&frame-name}.
display "" @ sch-code with frame {&frame-name}.

ppp =  string( day(pardoc-code)) + "/" +  string( month(pardoc-code)) + "/" +  string( year(pardoc-code)) .
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and buf-OR_ord-doc.doc-date = &1 "
      , ppp )
    ) no-error .
    if error-status :error or return-value = ? then
       message "За эту дату не найдено ни одной записи !" view-as alert-box .
apply "VALUE-CHANGED" to {&browse-name}  in frame {&frame-name}.


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sch-fact Dialog-Frame
PROCEDURE proc-sch-fact :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input parameter par-next as logical no-undo.
define input parameter pardoc-code as date no-undo.
define variable ppp as character no-undo .

display "" @ sch-date with frame {&frame-name}.
display "" @ sch-code with frame {&frame-name}.

ppp =  string( day(pardoc-code)) + "/" +  string( month(pardoc-code)) + "/" +  string( year(pardoc-code)) .
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and buf-OR_ord-doc.fact-date = &1 "
      , ppp )
    ) no-error .
    if error-status :error or return-value = ? then
       message "За эту дату не найдено ни одной записи !" view-as alert-box .
apply "VALUE-CHANGED" to {&browse-name}  in frame {&frame-name}.


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE run-rep Dialog-Frame
PROCEDURE run-rep :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------*/
define input parameter j as integer no-undo .

if j = 1 then run cus/g-ordrc1.p (ParParentproc).
if j = 2 then do :
   if par-mode begins "rc" then run cus/g-ordrc2.p (ParParentproc , "RC":U ).
   else  run cus/g-ordrc2.p (ParParentproc, "" ).

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on Dialog-Frame
PROCEDURE UI-on :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

 run openbr in this-procedure (yes, no, '':u).

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-direct Dialog-Frame
FUNCTION f-direct RETURNS CHARACTER
( par1 as recid ):
define buffer fl for ub.ord-doc.
define variable v-res as character no-undo .
define variable v-res-0 as character no-undo .
find first fl no-lock where recid(fl) = par1 no-error .
if error-status :error then return chr(32) .

v-res = chr(42) .
v-res-0 = chr(32) .
if v-cntxt-db-num = 0 then
    if fl.order-type = {&order-type-ubd}  then return v-res.
      else return v-res-0 .
else
   if fl.order-type = {&order-type-gbd}  then return v-res.
      else return v-res-0 .


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
