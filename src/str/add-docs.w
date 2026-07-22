&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_add-doc FOR ub.add-doc.
DEFINE BUFFER buf_add-trn FOR ub.add-trn.
DEFINE BUFFER buf_trn-doc FOR ub.trn-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список документов Дополнительных расходов

Автор: Чернова Светлана Александровна
Дата создания: 04/03/06
Author: Svetlana Chernova
Creation date: 04/03/06


*/
define input parameter parparentproc  as widget-handle no-undo.
define input parameter bttns          as character   no-undo .
define input parameter par-mode       as character   no-undo .
define input parameter pardoc-rec     as recid no-undo.
define input parameter par-host-code  like ub.clients.obj-code no-undo.
define input parameter p-obj-code     like ub.clients.obj-code no-undo.
define input parameter p-obj-type     like ub.clients.obj-type no-undo.
define input parameter p-doc-type     as character no-undo .
define input parameter p-status_      as character no-undo .
define input parameter p-char         as character no-undo .
define output parameter  rid-list     as character no-undo . /* список recid'ов выбранных */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список документов Дополнительных расходов".
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
define variable varlog as logical   no-undo .
define new shared variable next-prev as logical no-undo .
define variable doc-rec    as recid no-undo .

define temp-table x_add-trn no-undo like ub.add-trn .

{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ cmp/df-sub.i   }
{ cmp/gds-list.i gds-list def "new shared"}
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }

define variable pp as character no-undo .
define variable ff as character no-undo .

define buffer buf_sysconf for ub.sysconf  .
find first buf_sysconf where buf_sysconf.host-code = par-host-code no-lock.
define variable v-cntxt-cash-pay  as integer   no-undo .
define variable v-cntxt-in-ov     as logical   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
define variable v-cntxt-rsrv-time as integer   no-undo .
define variable v-cntxt-load-time as integer   no-undo .
define variable v-cntxt-holidays  as character no-undo .
define variable g#log as logical  no-undo .
assign
  v-cntxt-cash-pay   = buf_sysconf.cash-pay
  v-cntxt-base-code  = buf_sysconf.base-code
  v-cntxt-in-ov      = buf_sysconf.in-ov
  v-cntxt-rsrv-time  = buf_sysconf.rsrv-time
  v-cntxt-load-time  = buf_sysconf.load-time
  v-cntxt-holidays   = buf_sysconf.holidays
.

p-doc-type = {&income} .

&scop ver-paket ~
  if num-entries(rid-list) = 0  then do: ~
  message "Не отмечено ни одной записи !!!" . ~
  return .                                    ~
  end.                                        ~
  message "Запускать пакетный режим обработки для " num-entries(rid-list) "записей ?" ~
           view-as alert-box question                                                 ~
           buttons yes-no                                                             ~
           update g-ok                                                                ~
           .                                                                          ~
if g-ok = false then return.

define variable filter-point as character no-undo init "Список Дополнительных расходов" .
define variable filter-point0 as character no-undo init "Дополнительные расходы" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .

define new shared variable br-handle as handle  no-undo .
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
&scop col-l3  'ФО'
&scop col-l4  '№ док-та'
&scop col-l5  'Создан'
&scop col-l6  'Факт'
&scop col-l7  'Объект'
&scop col-l8  'Тип'
&scop col-l9  'Сумма ({&abbr_rub})'
&scop col-l10  'Счет-фактура'

&scop cop-l1             mark-string(recid(buf_add-doc),rid-list)
&scop dyn_sort-clmn_1    substitute('dynamic-function(&1mark-string&1, recid(buf_add-doc), &1&2&1)', ~{&double-quote~}, rid-list)
&scop cop-l2   buf_add-doc.status_
&scop cop-l3            fo-postavka(recid(buf_add-doc))
&scop dyn_sort-clmn_3   substitute('dynamic-function(&1fo-postavka&1,recid(buf_add-doc))',~{&double-quote~})
&scop cop-l4   buf_add-doc.doc-code
&scop cop-l5   buf_add-doc.doc-date
&scop cop-l6   buf_add-doc.fact-date
&scop cop-l7   buf_add-doc.obj-code
&scop cop-l8   buf_add-doc.obj-type
&scop cop-l9   buf_add-doc.sum-rubl
&scop cop-l10  sfactur(recid(buf_add-doc))
&scop dyn_sort-clmn_10   substitute('dynamic-function(&1sfactur&1, recid(buf_add-doc))', ~{&double-quote~})

function fo-postavka return character (input p-rec as recid ).
define buffer loc-t-doc for ub.add-doc  .
find first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error .
if error-status :error then return '' .

 if loc-t-doc.cr-incfo = yes then do:
   return string (loc-t-doc.incfo-date, '99/99/99').
 end.
 else do:
   if loc-t-doc.need-incfo = 0 then do:
     return '--------'.
   end.
   if loc-t-doc.need-incfo = 1 then do:
     return ''.
   end.
   if loc-t-doc.need-incfo = 2 then do:
     return 'не опред'.
   end.
 end.
end function.

function sfactur return character (input p-rec as recid).
define buffer loc-t-doc for ub.add-doc  .
find  first loc-t-doc no-lock where recid(loc-t-doc) = p-rec no-error .
if error-status :error then return '' .

 if loc-t-doc.cr-factur = yes then do:
   return string (loc-t-doc.factur-date, "99/99/99").
 end.
 else do:
   if loc-t-doc.need-factur = 0 then do:
     return "--------".
   end.
   if loc-t-doc.need-factur = 1 then do:
     return "".
   end.
   if loc-t-doc.need-factur = 2 then do:
     return "не опред".
   end.
 end.
end function.

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
&Scoped-define INTERNAL-TABLES buf_add-doc buf_add-trn buf_trn-doc

/* Definitions for BROWSE br-docs                                       */
&Scoped-define FIELDS-IN-QUERY-br-docs {&cop-l1} {&cop-l2} {&cop-l4} {&cop-l5} {&cop-l6} {&cop-l7} {&cop-l8} {&cop-l9} {&cop-l3} @ pp {&cop-l10} @ ff /* buf_add-doc.cr-incfo buf_add-doc.need-incfo buf_add-doc.incfo-date buf_add-doc.cr-factur buf_add-doc.need-factur */
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-docs {&cop-l2}
&Scoped-define SELF-NAME br-docs
&Scoped-define QUERY-STRING-br-docs FOR EACH buf_add-doc NO-LOCK by buf_add-doc.doc-date desc                                                      by buf_add-doc.doc-code desc
&Scoped-define OPEN-QUERY-br-docs OPEN QUERY {&SELF-NAME} FOR EACH buf_add-doc NO-LOCK by buf_add-doc.doc-date desc                                                      by buf_add-doc.doc-code desc .
&Scoped-define TABLES-IN-QUERY-br-docs buf_add-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-docs buf_add-doc


/* Definitions for BROWSE br-nakl                                       */
&Scoped-define FIELDS-IN-QUERY-br-nakl buf_trn-doc.doc-code buf_trn-doc.status_ buf_trn-doc.flag_ buf_trn-doc.cli-type + string(buf_trn-doc.cli-code) buf_trn-doc.obj-type + string(buf_trn-doc.obj-code) buf_trn-doc.doc-date buf_trn-doc.fact-date buf_trn-doc.tot-lines buf_trn-doc.fact-qnty buf_trn-doc.tot-rubl buf_trn-doc.contract-code buf_trn-doc.out-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-nakl
&Scoped-define SELF-NAME br-nakl
&Scoped-define QUERY-STRING-br-nakl FOR EACH buf_add-trn WHERE                   buf_add-trn.doc-code = buf_add-doc.doc-code NO-LOCK, ~
             EACH buf_trn-doc  where                  buf_trn-doc.doc-code =  buf_add-trn.trn-doc-code NO-LOCK
&Scoped-define OPEN-QUERY-br-nakl OPEN QUERY br-nakl FOR EACH buf_add-trn WHERE                   buf_add-trn.doc-code = buf_add-doc.doc-code NO-LOCK, ~
             EACH buf_trn-doc  where                  buf_trn-doc.doc-code =  buf_add-trn.trn-doc-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-nakl buf_add-trn buf_trn-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-nakl buf_add-trn
&Scoped-define SECOND-TABLE-IN-QUERY-br-nakl buf_trn-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-docs}~
    ~{&OPEN-QUERY-br-nakl}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sel b-rep b-close b-open ~
B-close-trn-all B-fo b-help b-mark b-add b-lkp b-chg b-del b-export b-sf ~
b-print b-sch sch-code sch-date sch-fact br-docs B-lkp-2 br-nakl sch-num ~
loc-creid
&Scoped-Define DISPLAYED-OBJECTS sch-code sch-date sch-fact sch-num ~
loc-creid

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU m-fo
       MENU-ITEM m_lookupFO     LABEL "Просмотр ФО"
       MENU-ITEM m_gen-1        LABEL "Генерация ФО"
       MENU-ITEM m_gen-2        LABEL "Отказаться от генерации ФО"
       MENU-ITEM m_gen-3        LABEL "Снять признак - есть генерация ФО"
       MENU-ITEM m_gen-4        LABEL "Снять 'не опред'".

DEFINE MENU m-sf
       MENU-ITEM m_lookupsf     LABEL "Просмотр счетов-фактур"
       MENU-ITEM m_gen-10       LABEL "Генерация счетов-фактур"
       MENU-ITEM m_gen-20       LABEL "Отказаться от генерации"
       MENU-ITEM m_gen-30       LABEL "Снять признак - есть генерация"
       MENU-ITEM m_gen-40       LABEL "Снять 'не опред'".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 9 BY 1 TOOLTIP "Добавить новый документ ДопРасх".

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 12 BY 1 TOOLTIP "Корректировка документа ДопРасх".

DEFINE BUTTON b-close
     LABEL "&Закрыть":L
     SIZE 12 BY 1 TOOLTIP "Закрыть документ ДопРасх".

DEFINE BUTTON B-close-trn
     LABEL "Закр&ыть ПН"
     SIZE 14.38 BY 1 TOOLTIP "Закрыть Приходную накладную".

DEFINE BUTTON B-close-trn-all
     LABEL "Закр&ыть ПН"
     SIZE 14.38 BY 1 TOOLTIP "Закрыть связанные Приходные накладные".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 12 BY 1 TOOLTIP "Удалитиь документ ДопРасх".

DEFINE BUTTON b-export
     LABEL "&Экспорт":L
     SIZE 12 BY 1 TOOLTIP "Экспорт в XML".

DEFINE BUTTON B-fo
     LABEL "ФинОбяз"
     SIZE 11 BY 1 TOOLTIP "Финансовые обязательства".

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 2.38 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 12 BY 1 TOOLTIP "Просмотр документа ДопРасх без корректировки".

DEFINE BUTTON B-lkp-2
     LABEL "Просмо&тр ПН"
     SIZE 12.5 BY 1 TOOLTIP "Просмотр приходной накладной".

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.

DEFINE BUTTON b-open
     LABEL "&Открыть":L
     SIZE 12 BY 1 TOOLTIP "Открыть".

DEFINE BUTTON b-print
     LABEL "Пе&ч":L
     SIZE 3 BY 1 TOOLTIP "Печать документа ДопРасх".

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 12 BY 1 TOOLTIP "Выход из режима".

DEFINE BUTTON b-rep
     LABEL "О&тчеты":L
     SIZE 12 BY 1 TOOLTIP "Список отчетов по документам ДопРасх".

DEFINE BUTTON b-sch
     LABEL "&Ф":L
     SIZE 3 BY 1 TOOLTIP "Фильтр по списку документов ДопРасх".

DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     SIZE 12 BY 1 TOOLTIP "Выход из режима и выбор текущего номера  документа ДопРасх".

DEFINE BUTTON b-sf
     LABEL "&СчетФакт":L
     SIZE 11 BY 1 TOOLTIP "Счета-фактуры".

DEFINE VARIABLE loc-creid AS CHARACTER FORMAT "X(256)":U
     LABEL "Создал"
      VIEW-AS TEXT
     SIZE 16.38 BY .67
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
     SIZE 9.63 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-docs FOR
      buf_add-doc SCROLLING.


DEFINE QUERY br-nakl FOR
      buf_add-trn,
      buf_trn-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-docs Dialog-Frame _FREEFORM
  QUERY br-docs NO-LOCK DISPLAY
      {&cop-l1} COLUMN-LABEL {&col-l1} FORMAT "X(1)"
      {&cop-l2} COLUMN-LABEL {&col-l2} Format "X(6)"
      {&cop-l4} COLUMN-LABEL {&col-l4}
      {&cop-l5} COLUMN-LABEL {&col-l5} FORMAT "99/99/99"
      {&cop-l6} COLUMN-LABEL {&col-l6} FORMAT "99/99/99"
      {&cop-l7} COLUMN-LABEL {&col-l7} format ">>>>9"
      {&cop-l8} COLUMN-LABEL {&col-l8} format "x(3)"
      {&cop-l9} COLUMN-LABEL {&col-l9} format ">>>>>>>>>9.99"
      {&cop-l3}  @ pp  COLUMN-LABEL {&col-l3}  format "X(11)"
      {&cop-l10} @ ff COLUMN-LABEL {&col-l10} format "X(11)"
      /*
      buf_add-doc.cr-incfo
      buf_add-doc.need-incfo
      buf_add-doc.incfo-date

      buf_add-doc.cr-factur
      buf_add-doc.need-factur
      */
  ENABLE
       {&cop-l2}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.38 BY 9.83
         BGCOLOR 15 .

DEFINE BROWSE br-nakl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-nakl Dialog-Frame _FREEFORM
  QUERY br-nakl NO-LOCK DISPLAY
      buf_trn-doc.doc-code
      buf_trn-doc.status_ COLUMN-LABEL "Стат" FORMAT "X(4)"
      buf_trn-doc.flag_ COLUMN-LABEL "Ок" FORMAT "+/-"
      buf_trn-doc.cli-type + string(buf_trn-doc.cli-code)  COLUMN-LABEL "Контрагент"
      buf_trn-doc.obj-type + string(buf_trn-doc.obj-code)  COLUMN-LABEL "Объект"
      buf_trn-doc.doc-date
      buf_trn-doc.fact-date
      buf_trn-doc.tot-lines
      buf_trn-doc.fact-qnty COLUMN-LABEL "Количество" FORMAT ">>>>>>>>9.<<<"
      buf_trn-doc.tot-rubl  COLUMN-LABEL "Сумма ({&abbr_rub})" FORMAT ">>>>>>>>>9.99"
      buf_trn-doc.contract-code COLUMN-LABEL "Вн.№ дог."
      buf_trn-doc.out-code COLUMN-LABEL "Ссылка"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 94.75 BY 8.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 2
     b-sel AT ROW 1 COL 14
     b-rep AT ROW 1 COL 26
     b-close AT ROW 1 COL 38
     b-open AT ROW 1 COL 50
     B-close-trn-all AT ROW 1 COL 62 WIDGET-ID 2
     B-fo AT ROW 1 COL 76.5 WIDGET-ID 4
     b-help AT ROW 1 COL 94
     b-mark AT ROW 2 COL 2
     b-add AT ROW 2 COL 5
     b-lkp AT ROW 2 COL 14
     b-chg AT ROW 2 COL 26
     b-del AT ROW 2 COL 38
     b-export AT ROW 2 COL 50 WIDGET-ID 6
     b-sf AT ROW 2 COL 76.5 WIDGET-ID 8
     b-print AT ROW 2 COL 93
     b-sch AT ROW 3 COL 93
     sch-code AT ROW 3.08 COL 26 COLON-ALIGNED
     sch-date AT ROW 3.08 COL 47 COLON-ALIGNED
     sch-fact AT ROW 3.08 COL 65.75 COLON-ALIGNED
     br-docs AT ROW 4.21 COL 1
     B-lkp-2 AT ROW 14.21 COL 1.5
     B-close-trn AT ROW 14.21 COL 14.13
     br-nakl AT ROW 15.25 COL 1.5
     sch-num AT ROW 3.25 COL 80.38 COLON-ALIGNED NO-LABEL
     loc-creid AT ROW 14.33 COL 78 COLON-ALIGNED
     " Поиск по:" VIEW-AS TEXT
          SIZE 10.13 BY .67 AT ROW 3.25 COL 1.63
          BGCOLOR 3 FGCOLOR 15
     SPACE(84.62) SKIP(19.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список Дополнительных расходов".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_add-doc B "?" ? ub add-doc
      TABLE: buf_add-trn B "?" ? ub add-trn
      TABLE: buf_trn-doc B "?" ? ub trn-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-docs sch-fact Dialog-Frame */
/* BROWSE-TAB br-nakl B-close-trn Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-close-trn IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-close-trn:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-fo:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-fo:HANDLE.

ASSIGN
       b-sf:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-sf:HANDLE.

ASSIGN
       br-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-docs
/* Query rebuild information for BROWSE br-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_add-doc NO-LOCK by buf_add-doc.doc-date desc
                                                     by buf_add-doc.doc-code desc .
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-docs FOR
      buf_add-doc SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE br-docs */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-nakl
/* Query rebuild information for BROWSE br-nakl
     _START_FREEFORM
OPEN QUERY br-nakl FOR EACH buf_add-trn WHERE
                  buf_add-trn.doc-code = buf_add-doc.doc-code NO-LOCK,
      EACH buf_trn-doc  where
                 buf_trn-doc.doc-code =  buf_add-trn.trn-doc-code NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "buf_add-trn.doc-code = buf_add-doc.doc-code"
     _JoinCode[2]      = "buf_add-trn.doc-code = buf_add-doc.doc-code"
     _Query            is OPENED
*/  /* BROWSE br-nakl */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список Дополнительных расходов */
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
  find current buf_add-doc exclusive-lock no-error .  /* сетевая проверка */
end.

define variable rr as recid no-undo .
define buffer buf_clients for ub.clients.
define buffer obj_clients for ub.clients.



 if not available buf_add-doc then return.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_add-d_update':U
    {&cntxt-object}
    buf_add-doc.host-code
    buf_add-doc.obj-type
    buf_add-doc.obj-code
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .

   if not ( buf_add-doc.status_ = {&g___new}  ) then do:
      message "Нельзя корректировать документ ДопРасх! " view-as alert-box  .
      return.
  end.

  if   buf_add-doc.status_ = {&g___new}  and
        not (p-obj-code = buf_add-doc.obj-code and
             p-obj-type = buf_add-doc.obj-type ) then do:
    message "Корректирование в этом статусе возможно на объекте: "
        buf_add-doc.obj-code
        buf_add-doc.obj-type
        view-as alert-box error .
        return .
  end.

  rr = recid(buf_add-doc) .
  run str/add-docu.w
    ( input parparentproc,
      input-output rr ,
      input {&update},
      input "" ) .
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
  if not available buf_add-doc then return.
  rr = recid(buf_add-doc) .
  run proc-close-add-doc in this-procedure  .
  run openbr in this-procedure (yes, no, '':u).
  reposition {&browse-name} to recid rr no-error.
  apply "value-changed" to br-docs in frame dialog-frame.
  apply "entry" to br-docs in frame dialog-frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-close-trn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-close-trn Dialog-Frame
ON CHOOSE OF B-close-trn IN FRAME Dialog-Frame /* Закрыть ПН */
DO:
    /*закроем ЗАПР  */

 if not available buf_trn-doc   then return.
 message "Закрыть накладную ?"
  view-as alert-box question
  buttons yes-no
  update g-log
  .
  if g-log = false then return no-apply.
  run close-nakl in this-procedure ( input buf_trn-doc.doc-code ) .
  {&OPEN-QUERY-br-nakl}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-close-trn-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-close-trn-all Dialog-Frame
ON CHOOSE OF B-close-trn-all IN FRAME Dialog-Frame /* Закрыть ПН */
DO:
 define variable rr as recid no-undo .

 if not available buf_add-doc then return.
 if buf_add-doc.status_ <> {&fact} then do:
    message 'Документ ДопРасходов должен быть закрыт на факт' view-as alert-box information .
    return no-apply.
 end.

  message "Закрыть накладные по документу ДопРасходов ?"
    view-as alert-box question
    buttons yes-no
    update g-log
    .

  if g-log = false then return no-apply.
  rr = recid(buf_add-doc) .
  run close-all ( buf_add-doc.doc-code ) no-error .
  if error-status :error then
     message 'Не удалось закрыть ПН !' view-as alert-box information .
  else do:

  run openbr in this-procedure (yes, no, '':u).
  reposition {&browse-name} to recid rr no-error.
  {&OPEN-QUERY-br-nakl}
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
if not available buf_add-doc then return.

do on stop undo, return no-apply :
  find current buf_add-doc exclusive-lock .  /* сетевая проверка */
end.

  if   not (p-obj-code = buf_add-doc.obj-code and
            p-obj-type = buf_add-doc.obj-type ) then do:
    message "Удалить этом статусе возможно на объекте: "
      buf_add-doc.obj-code
      buf_add-doc.obj-type
      view-as alert-box error .
      return .
  end.

  define buffer bufs_add-trn for ub.add-trn  .
  define variable v-i as integer   no-undo .
  define variable v-s as character no-undo .
  v-i = 0.
  v-s = "" .
  for each  bufs_add-trn no-lock where
            bufs_add-trn.doc-code = buf_add-doc.doc-code :
      v-i = v-i + 1.
      v-s = v-s + bufs_add-trn.trn-doc-code + ',' .
  end.
  v-s = trim(v-s ,',') .
  if v-i > 1 then do:
     message
      substitute("К ДопРасх № &1 прикреплены &2 ПН : &3. Удалеем ? " ,buf_add-doc.doc-code , v-i, v-s )
      view-as alert-box question
      buttons yes-no
      update vok as log
     .
     if vok = false then return .
  end.
  run ord-del in this-procedure ( recid ( buf_add-doc ) ) no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Ошибка из ord-del"
    view-as alert-box error
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-export Dialog-Frame
ON CHOOSE OF b-export IN FRAME Dialog-Frame /* Экспорт */
DO:
  if not available buf_add-doc then return.
  run export-doc in this-procedure ( buf_add-doc.doc-code ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-fo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-fo Dialog-Frame
ON CHOOSE OF B-fo IN FRAME Dialog-Frame /* ФинОбяз */
DO:
/**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
 if not available buf_add-doc then return .
 define variable rr as recid no-undo .
 rr = recid(buf_add-doc) .
      br-handle = {&browse-name}:handle in frame {&frame-name} .
      next-prev = no.
      do while next-prev <> ?:
        if not available buf_add-doc then do:
          message "Неправильный выбор документа.".
          return no-apply.
        end.
          run str/add-docu.w
             ( input parparentproc,
               input-output rr ,
               input {&lookup} ,
               input "" ).
          v-doc-rec = rr .
          next-prev = ?.
        if br-handle = ? then reposition {&browse-name} to recid rr no-error.
      end.
apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp-2 Dialog-Frame
ON CHOOSE OF B-lkp-2 IN FRAME Dialog-Frame /* Просмотр ПН */
DO:
   if not available buf_trn-doc then return .

      run str/showdoc.p
          (input parparentproc
          ,input buf_trn-doc.doc-code
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
        if available buf_add-doc then do:
        { gbl/markstrn.i buf_add-doc rid-list }

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
  if not available buf_add-doc then return.
  rr = recid(buf_add-doc) .
  run ord-open in this-procedure (recid(buf_add-doc)) .
  run openbr in this-procedure (yes, no, '':u).
  reposition {&browse-name} to recid rr no-error.
  apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
  apply "entry" TO BR-docs IN FRAME Dialog-Frame.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печ */
DO:

  find current buf_add-doc no-lock no-error .
  if not available buf_add-doc then return .
  run proc-print .

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


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Ф */
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
    if ( available buf_add-doc ) AND ( rid-list = "" ) then
    rid-list = string( recid( buf_add-doc ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-docs
&Scoped-define SELF-NAME br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-docs Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-docs IN FRAME Dialog-Frame
DO:
apply  "CHOOSE":U to b-lkp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-docs Dialog-Frame
ON VALUE-CHANGED OF br-docs IN FRAME Dialog-Frame
DO:
 if not available buf_add-doc then return .
 define buffer buf_clients for ub.clients.
  { gbl/usrfulnm.i
    buf_add-doc.creid
    loc-creid
    }

  display loc-creid with frame {&frame-name} .
  {&OPEN-QUERY-br-nakl}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gen-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-1 /* Генерация ФО */
DO:
define variable rr as recid no-undo .
define variable vari as integer   no-undo .
define variable vardoc-code as character no-undo .
if rid-list = "" then do:
  if available buf_add-doc then do:
    assign
      rid-list = string(recid(buf_add-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (rid-list):
  assign
    vardoc-code = entry (vari, rid-list).
    find first buf_add-doc no-lock where
               recid(buf_add-doc) = int(vardoc-code) no-error .
 if error-status :error then do:
    next.
 end.

 if buf_add-doc.status_ <> {&fact} then do:
    message 'Документ ДопРасходов должен быть закрыт на факт' view-as alert-box information .
    return no-apply.
 end.

  message "Сгенерить ФО по документу ДопРасходов " buf_add-doc.doc-code " ?  "
    view-as alert-box question
    buttons yes-no
    update g-log
    .

  if g-log = false then next.

  rr = recid (buf_add-doc) .
  run make-fo  no-error .
    if error-status :error then do:
      message 'Не удалось создать ФО!' view-as alert-box information .
    end.
 end.

run openbr in this-procedure (yes, no, '':u).
reposition {&browse-name} to recid rr no-error.
{&OPEN-QUERY-br-nakl}

END.

ON CHOOSE OF MENU-ITEM m_gen-10 /* Генерация CФ */
DO:
define variable rr as recid no-undo .

 if not available buf_add-doc then return.
 if buf_add-doc.status_ <> {&fact} then do:
    message 'Документ ДопРасходов должен быть закрыт на факт' view-as alert-box information .
    return no-apply.
 end.

  message "Сгенерить Счет-Фактуру ?  "
    view-as alert-box question
    buttons yes-no
    update g-log
    .

  if g-log = false then return no-apply.

  if rid-list = "" then do:
    if available buf_add-doc then do:
      assign
        rid-list = string(recid(buf_add-doc)).
    end.
  end.

  rr = recid(buf_add-doc) .
  run make-sf  no-error .
  if error-status :error then
     message 'Не удалось создать Счет-Фактуру!' view-as alert-box information .
  else do:

  run openbr in this-procedure (yes, no, '':u).
  reposition {&browse-name} to recid rr no-error.
  {&OPEN-QUERY-br-nakl}
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gen-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-2 /* Отказаться от генерации ФО */
DO:
   run gen-2 .
END.
ON CHOOSE OF MENU-ITEM m_gen-3 /* Отказаться от генерации ФО */
DO:
   run gen-3 .
END.
ON CHOOSE OF MENU-ITEM m_gen-4 /* Отказаться от генерации ФО */
DO:
   run gen-4 .
END.
ON CHOOSE OF MENU-ITEM m_gen-20 /* Отказаться от генерации ФО */
DO:
   run gen-20 .
END.
ON CHOOSE OF MENU-ITEM m_gen-30 /* Отказаться от генерации ФО */
DO:
   run gen-30 .
END.
ON CHOOSE OF MENU-ITEM m_gen-40 /* Отказаться от генерации ФО */
DO:
   run gen-40 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookupFO
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookupFO Dialog-Frame
ON CHOOSE OF MENU-ITEM m_lookupFO /* Просмотр ФО */
DO:
 if not available buf_add-doc then return.
    run str/fi-trns.w (
        input parparentproc,
        input v-cntxt-host-code-obj ,
        input ?              ,
        input buf_add-doc.doc-code ,
        input "add":U
   ) .
END.

ON CHOOSE OF MENU-ITEM m_lookupSF
DO:
define variable v-rid-list as character no-undo .
 if not available buf_add-doc then return.

  run str/s-f-docs.w
    ( input parparentproc,
      input buf_add-doc.host-code,
      ?,
      ?,
      ?,
      {&SFEDT_add_doc} ,
      {&SFEDT_add_doc} ,
      buf_add-doc.doc-code,
      "" ,
      input "in-doc",
      input-output v-rid-list
      ) no-error .

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
assign b-fo :popup-menu in frame {&frame-name} = menu m-fo :handle.
assign b-fo :menu-mouse = 1.
assign b-fo :menu-key   = "return":u.
assign b-sf :popup-menu in frame {&frame-name} = menu m-sf :handle.
assign b-sf :menu-mouse = 1.
assign b-sf :menu-key   = "return":u.

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
  &table-name     = "buf_add-doc"
  &label-clmn_1     = "{&col-l1}"
  &label-clmn_2     = "{&col-l2}"
  &label-clmn_3     = "{&col-l3}"
  &label-clmn_4     = "{&col-l4}"
  &label-clmn_5     = "{&col-l5}"
  &label-clmn_6     = "{&col-l6}"
  &label-clmn_7     = "{&col-l7}"
  &label-clmn_8     = "{&col-l8}"
  &label-clmn_9     = "{&col-l9}"
  &label-clmn_10    = "{&col-l10}"
  &sort-clmn_1    =   "{&cop-l1}"
  &dyn_sort-clmn_1  = "{&dyn_sort-clmn_1}"
  &sort-clmn_2    =   "{&cop-l2}"
  &sort-clmn_3    =   "{&cop-l3}"
  &dyn_sort-clmn_3  = "{&dyn_sort-clmn_3}"
  &sort-clmn_4    =   "{&cop-l4}"
  &sort-clmn_5    =   "{&cop-l5}"
  &sort-clmn_6    =   "{&cop-l6}"
  &sort-clmn_7    =   "{&cop-l7}"
  &sort-clmn_8    =   "{&cop-l8}"
  &sort-clmn_9    =   "{&cop-l9}"
  &sort-clmn_10   =   "{&cop-l10}"
  &dyn_sort-clmn_10  = "{&dyn_sort-clmn_10}"
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
   disable  b-rep with frame {&frame-name} .


   define buffer find_code for ub.add-doc.
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
      ,input  browse br-nakl :handle
      ) .

  run diasize_init in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-docs.

END.
run disable_ui in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE close-all Dialog-Frame
PROCEDURE close-all :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter  p-doc-code as character no-undo .
define variable varcheck-return as logical no-undo .
define variable varchg-inv as logical no-undo .

define buffer buf_trn-doc for ub.trn-doc  .
tr:
do transaction
   ON ERROR   UNDO tr, LEAVE
   ON END-KEY UNDO tr, LEAVE
   ON STOP    UNDO tr , LEAVE :

for each ub.add-trn no-lock where
         ub.add-trn.doc-code = p-doc-code :
     find first  buf_trn-doc no-lock where
                 buf_trn-doc.doc-code = ub.add-trn.trn-doc-code
                 no-error .
     if not available buf_trn-doc then do:
        message 'Не найдена ПН с №' ub.add-trn.trn-doc-code
        view-as alert-box information .
        undo, return error return-value .
     end.

     if buf_trn-doc.tot-other  <> 0 or
        buf_trn-doc.tot-transp <> 0 then do:
          run str/add-exp.p (input parparentproc,
                          input buf_trn-doc.doc-code ,
                          input buf_trn-doc.tot-other  * buf_trn-doc.exch-rate / buf_trn-doc.exch-scale,
                          input buf_trn-doc.tot-transp * buf_trn-doc.exch-rate / buf_trn-doc.exch-scale) no-error.
          if error-status :error
          then do:
            undo, return error substitute ( "Ошибка при установке дополнительных расходов &1 .", return-value ).
          end.
     end.
end.

run str/addsuper.p (parparentproc , p-doc-code ) no-error .
if error-status :error then do:
   message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "Ошибка размазывания ДопРасходов в учетную цену  (addsuper.p)"
     view-as alert-box error
   .
   undo, return error return-value .
end.

for each ub.add-trn no-lock where
         ub.add-trn.doc-code = p-doc-code:
     find first  buf_trn-doc no-lock where
                 buf_trn-doc.doc-code = ub.add-trn.trn-doc-code no-error .
     if available buf_trn-doc then do:
        /* закроем сразу на ФАКТ */
           run str/trn-stat.p (
                input  parparentproc ,
                input  this-procedure  ,
                input  (if buf_trn-doc.flag_  then  {&close-doc} else  {&close-fact}) ,
                input  buf_trn-doc.doc-code,
                input  varcheck-return  ,
                input  v-cntxt-db-num   ,
                input  v-cntxt-in-ov    ,
                input  v-cntxt-rsrv-time,
                input  v-cntxt-load-time,
                input  v-cntxt-holidays ,
                input  yes ,
                output varchg-inv ,
                output table gds-list) no-error .
          if error-status:error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при принудительном закрытии документа " buf_trn-doc.doc-code skip
              return-value skip
              error-status :get-message(1)
              view-as alert-box error.
            undo, return error return-value .
          end.
     end.
end.


end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE close-nakl Dialog-Frame
PROCEDURE close-nakl :
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
    input  this-procedure  ,
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
    output table gds-list)
no-error.
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
  DISPLAY sch-code sch-date sch-fact sch-num loc-creid
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-sel b-rep b-close b-open B-close-trn-all B-fo b-help b-mark
         b-add b-lkp b-chg b-del b-export b-sf b-print b-sch sch-code sch-date
         sch-fact br-docs B-lkp-2 br-nakl sch-num loc-creid
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-doc Dialog-Frame
PROCEDURE export-doc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter par-doc-code as character no-undo .
define variable varxmldocfl      as character no-undo.
define variable varxmldocfl-type as character no-undo.
define variable v-file-name as character no-undo .
define variable for-dir as character no-undo .
define variable accum-count as integer no-undo init 0.
define variable accum-count-ok as integer no-undo init 0 .
define variable loclog as logical no-undo .
define variable ii as integer no-undo .
define variable ii0 as integer no-undo .


if not available buf_add-doc then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.

assign
v-file-name =  ?
.
run bge/xmladd.p ( input buf_add-doc.host-code, buf_add-doc.doc-code, input-output v-file-name, yes, yes) no-error .

define variable v-sys-key   as character         no-undo.

{ gbl/currsysk.i
  v-sys-key
  no-error
}

if search ("exmldoc.bat") <> ? then do:
  os-command silent value(search ("exmldoc.bat") + " " + v-file-name + " " + v-sys-key).
end.
else do:
  if search (v-file-name ) <> ? then do:
    if accum-count-ok  > 1 then
       message "ДопРасходы выгружены в файл " v-file-name view-as alert-box.
    else
      message "ДопРасход выгружен в файл " v-file-name view-as alert-box.
  end.
end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gen-2 Dialog-Frame
PROCEDURE gen-2 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer bf_sysconf for ub.sysconf.
define buffer bf_add-doc for ub.add-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
do
on error undo, return error return-value
:
if rid-list = "" then do:
  if available buf_add-doc then do:
    assign
      rid-list = string(recid(buf_add-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (rid-list):
  assign
    vardoc-code = integer(entry (vari, rid-list)).
  find first bf_add-doc where recid(bf_add-doc) = vardoc-code exclusive-lock.
  if bf_add-doc.status_ <> {&fact} then do:
    message "Документ " bf_add-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next vari-cycle.
  end.
  find first bf_sysconf where bf_sysconf.host-code = bf_add-doc.host-code no-lock.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_add-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box error.
    next vari-cycle.
  end.
  if bf_add-doc.cr-incfo = yes then do:
    message "По документу " bf_add-doc.doc-code " уже генерилось финансовое обязательство от " bf_add-doc.incfo-date " числа."
    view-as alert-box.
    next vari-cycle.
  end.
  else do:
    if bf_add-doc.need-incfo = 1 or
       bf_add-doc.need-incfo = 2 then do:
      assign
        bf_add-doc.need-incfo = 0.
    end.
    else do:
      message "Данный документ не нуждался в генерации финобязательств по поставке."
      view-as alert-box.
      next vari-cycle.
    end.
    reposition {&browse-name} to recid recid(bf_add-doc) no-error.
    if not error-status:error then do:
      display fo-postavka(recid( bf_add-doc)) @ pp with browse {&browse-name}.
    end.
  end.
end.
assign
  rid-list = "".
end.

END PROCEDURE.
PROCEDURE gen-20 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer bf_sysconf for ub.sysconf.
define buffer bf_add-doc for ub.add-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
do
on error undo, return error return-value
:
if rid-list = "" then do:
  if available buf_add-doc then do:
    assign
      rid-list = string(recid(buf_add-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (rid-list):
  assign
    vardoc-code = integer(entry (vari, rid-list)).
  find first bf_add-doc where recid(bf_add-doc) = vardoc-code exclusive-lock.
  if bf_add-doc.status_ <> {&fact} then do:
    message "Документ " bf_add-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next vari-cycle.
  end.
  find first bf_sysconf where bf_sysconf.host-code = bf_add-doc.host-code no-lock.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_add-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box error.
    next vari-cycle.
  end.
  if bf_add-doc.cr-factur = yes then do:
    message "По документу " bf_add-doc.doc-code " уже создавались счета-фактуры от " bf_add-doc.factur-date " числа."
    view-as alert-box.
    next vari-cycle.
  end.
  else do:
    if bf_add-doc.need-factur = 1 or
       bf_add-doc.need-factur = 2 then do:
      assign
        bf_add-doc.need-factur = 0.
    end.
    else do:
      message "Данный документ не нуждался в генерации счетов-фактур."
      view-as alert-box.
      next vari-cycle.
    end.
    reposition {&browse-name} to recid recid(bf_add-doc) no-error.
    if not error-status:error then do:
      display sfactur (recid( bf_add-doc)) @ ff with browse {&browse-name}.
    end.
  end.
end.
assign
  rid-list = "".
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gen-3 Dialog-Frame
PROCEDURE gen-3 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer bf_sysconf for ub.sysconf.
define buffer bf_add-doc for ub.add-doc.
define variable vari        as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varcr-incfo as logical no-undo.
define variable varinc-exp  as integer no-undo.
define buffer buf_parts    for ub.parts.
define buffer buf_contract for ub.contract.

do
on error undo, return error return-value
:
if rid-list = "" then do:
  if available buf_add-doc then do:
    assign
      rid-list = string(recid(buf_add-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (rid-list):
  assign
    vardoc-code = integer(entry (vari, rid-list)).
  find first bf_add-doc where recid(bf_add-doc) = vardoc-code exclusive-lock.
  find first bf_sysconf where bf_sysconf.host-code = bf_add-doc.host-code no-lock.
  if bf_add-doc.status_ <> {&fact} then do:
    message "Документ " bf_add-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next vari-cycle.
  end.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_add-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box error.
    next vari-cycle.
  end.
  if bf_add-doc.cr-incfo = yes then do:
    assign
      varlog = no.
    message "По документу " bf_add-doc.doc-code " было создано финансовое обязательство от " bf_add-doc.incfo-date " ." skip
            "Вы действительно хотите снять признак, что по этому документу было создано фин. обязательство?"
    view-as alert-box question buttons yes-no update varlog.
    if varlog <> yes then do:
      next vari-cycle.
    end.
    assign
      bf_add-doc.cr-incfo   = no
      bf_add-doc.incfo-date = 01/01/1990.
    reposition {&browse-name} to recid recid(bf_add-doc) no-error.
    if not error-status:error then do:
      display fo-postavka (recid( bf_add-doc)) @ pp with browse {&browse-name}.
    end.
  end.
  else do:
    message "По документу " bf_add-doc.doc-code " не было генерации по поставке."
    view-as alert-box.
  end.
end.
assign
  rid-list = "".
end.

END PROCEDURE.
PROCEDURE gen-30 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer bf_sysconf for ub.sysconf.
define buffer bf_add-doc for ub.add-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varcr-incfo as logical no-undo.
define variable varinc-exp  as integer no-undo.
define buffer buf_parts    for ub.parts.
define buffer buf_contract for ub.contract.

do
on error undo, return error return-value
:
if rid-list = "" then do:
  if available buf_add-doc then do:
    assign
      rid-list = string(recid(buf_add-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (rid-list):
  assign
    vardoc-code = integer(entry (vari, rid-list)).
  find first bf_add-doc where recid(bf_add-doc) = vardoc-code exclusive-lock.
  find first bf_sysconf where bf_sysconf.host-code = bf_add-doc.host-code no-lock.
  if bf_add-doc.status_ <> {&fact} then do:
    message "Документ " bf_add-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next vari-cycle.
  end.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_add-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box error.
    next vari-cycle.
  end.
  if bf_add-doc.cr-factur = yes then do:
    assign
      varlog = no.
    message "По документу " bf_add-doc.doc-code " были созданы счета-фактуры от " bf_add-doc.factur-date " ." skip
            "Вы действительно хотите снять признак, что по этому документу были созданы счета-фактуры ?"
    view-as alert-box question buttons yes-no update varlog.
    if varlog <> yes then do:
      next vari-cycle.
    end.
    assign
      bf_add-doc.cr-factur   = no
      bf_add-doc.factur-date = 01/01/1990.
    reposition {&browse-name} to recid recid(bf_add-doc) no-error.
    if not error-status:error then do:
      display sfactur (recid( bf_add-doc)) @ ff with browse {&browse-name}.
    end.
  end.
  else do:
    message "По документу " bf_add-doc.doc-code " не было генерации."
    view-as alert-box.
  end.
end.
assign
  rid-list = "".
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gen-4 Dialog-Frame
PROCEDURE gen-4 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer bf_sysconf for ub.sysconf.
define buffer bf_add-doc for ub.add-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varneed-incfo as logical no-undo.
define buffer bf_add-line    for ub.add-line.
define buffer bf_contract for ub.contract.
do
on error undo, return error return-value
:
if rid-list = "" then do:
  if available buf_add-doc then do:
    assign
      rid-list = string(recid(buf_add-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (rid-list):
  assign
    vardoc-code = integer(entry (vari, rid-list)).
  find first bf_add-doc where recid(bf_add-doc) = vardoc-code exclusive-lock.
  find first bf_sysconf where bf_sysconf.host-code = bf_add-doc.host-code no-lock.
  if bf_add-doc.status_ <> {&fact} then do:
    message "Документ " bf_add-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next.
  end.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_add-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box error.
    return error.
  end.
  if bf_add-doc.need-incfo = 2 then do:
    assign
      varneed-incfo = no.
    for each bf_add-line where bf_add-line.doc-code = bf_add-doc.doc-code on error undo, return error return-value :
      if bf_add-line.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = bf_add-line.host-code   and
                                     bf_contract.contract-code = bf_add-line.contract-code no-lock no-error.
        if available bf_contract then do:
          if lookup (bf_contract.usl-opl, {&o-postavka}) > 0 then do:
            assign
              varneed-incfo = yes.
          end.
        end.
      end.
    end.
    if varneed-incfo then do:
      assign
        bf_add-doc.need-incfo      = 1
      .
      reposition {&browse-name} to recid recid(bf_add-doc) no-error.
      if not error-status:error then do:
         display fo-postavka (recid( bf_add-doc)) @ pp with browse {&browse-name}.
      end.
    end.
    else do:
      message "По документу " bf_add-doc.doc-code " нет договоров для генерации ФО по поставке."
      view-as alert-box.
    end.
  end.
  else do:
    message "Документ " bf_add-doc.doc-code "не имеет признака 'не опред' генерация ФО по поставке."
    view-as alert-box.
    next vari-cycle.
  end.
end.
assign
  rid-list = "".
end.

END PROCEDURE.
PROCEDURE gen-40 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer bf_sysconf for ub.sysconf.
define buffer bf_add-doc for ub.add-doc.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varneed-factur as logical no-undo.
define buffer bf_add-line    for ub.add-line.
define buffer bf_contract for ub.contract.
do
on error undo, return error return-value
:
if rid-list = "" then do:
  if available buf_add-doc then do:
    assign
      rid-list = string(recid(buf_add-doc)).
  end.
end.
vari-cycle:
do vari = 1 to num-entries (rid-list):
  assign
    vardoc-code = integer(entry (vari, rid-list)).
  find first bf_add-doc where recid(bf_add-doc) = vardoc-code exclusive-lock.
  find first bf_sysconf where bf_sysconf.host-code = bf_add-doc.host-code no-lock.
  if bf_add-doc.status_ <> {&fact} then do:
    message "Документ " bf_add-doc.status_ " не в статусе " {&fact} " . Пропускаем."
    view-as alert-box.
    next.
  end.
  if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
    message "Главная БД для фирмы по документу с кодом " bf_add-doc.doc-code " не является текущей БД." skip
            "Текущая БД: " v-cntxt-db-num skip
            "Главная БД фирмы: " bf_sysconf.firm-db-num
    view-as alert-box error.
    return error.
  end.
  if bf_add-doc.need-factur = 2 then do:
    assign
      varneed-factur = no.
    for each bf_add-line where bf_add-line.doc-code = bf_add-doc.doc-code on error undo, return error return-value :
      if bf_add-line.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = bf_add-line.host-code   and
                                     bf_contract.contract-code = bf_add-line.contract-code no-lock no-error.
        if available bf_contract then do:
          if lookup (bf_contract.usl-opl, {&o-postavka}) > 0 then do:
            assign
              varneed-factur = yes.
          end.
        end.
      end.
    end.
    if varneed-factur then do:
      assign
        bf_add-doc.need-factur      = 1
      .
      reposition {&browse-name} to recid recid(bf_add-doc) no-error.
      if not error-status:error then do:
        display sfactur (recid( bf_add-doc)) @ ff with browse {&browse-name}.
      end.
    end.
    else do:
      message "По документу " bf_add-doc.doc-code " нет договоров для генерации счетов-фактур."
      view-as alert-box.
    end.
  end.
  else do:
    message "Документ " bf_add-doc.doc-code "не имеет признака 'не опред' генерация Счетов-фактур."
    view-as alert-box.
    next vari-cycle.
  end.
end.
assign
  rid-list = "".
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-fo Dialog-Frame
PROCEDURE make-fo :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 if num-entries(rid-list) = 0 then do:
    message "Не выделено ни одного документа для генерации финансовых обязательств !".
    return error .
 end.

 run str/gen-fl.w (
    input parparentproc,
    input v-cntxt-host-code-obj ,
    input rid-list,
    input "add"
 )   .

  assign
    rid-list = ""
    .
END PROCEDURE.
PROCEDURE make-sf :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf1_add-doc for ub.add-doc  .
define variable v-list as character no-undo .
 if num-entries(rid-list) = 0 then do:
    message "Не выделено ни одного документа для генерации счетов-фактур !".
    return error .
 end.

define variable v-9 as integer   no-undo .
define variable vari as integer   no-undo .

v-9 = num-entries (rid-list).
do vari = 1 to v-9 :
 find first buf1_add-doc exclusive-lock where
            recid(buf1_add-doc) = int(entry(vari, rid-list)) no-error  .
 if available buf1_add-doc then
 run str/gen-scf.p ( input parParentProc, input recid(buf1_add-doc), input "add-doc", output v-list) no-error .
 if error-status :error then message
   vss-workfile vss-revision vss-description skip
   error-status :get-message(1) skip
   return-value skip
   "Ошибка из str/gen-scf.p"
   view-as alert-box error
 .
end.
  assign
    rid-list = ""
    .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE many-add-docs Dialog-Frame
PROCEDURE many-add-docs :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define output parameter p-reply as logical   no-undo .
p-reply = true .

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
 define variable is-finvalue as character no-undo .
 define variable is-fintype as character no-undo .
 { gbl/conf-rd.i  "'is-fin'"   "''" "''" 0 "''" "''" "''" no is-finvalue is-fintype   no-error }
   if error-status :error then is-finvalue = 'no' .


  DISPLAY
      sch-code
      sch-date
      sch-fact
      WITH FRAME Dialog-Frame.
  ENABLE b-quit
         b-mark       when ( lookup("b-mark":U,  bttns) > 0  or is-finvalue = 'yes' )
         b-sel        when lookup("b-sel":U,   bttns) > 0
         b-sch
         b-help
         b-add        when lookup("b-add":U,  bttns) > 0
         b-lkp
         b-lkp-2
         b-chg        when lookup("b-chg":U,  bttns) > 0
         b-del        when lookup("b-del":U,  bttns) > 0
         b-close
       /*  b-close-trn-all*/
         b-open
         b-print
         sch-code
         sch-date
         sch-fact
         br-docs
         br-nakl
         b-rep
         b-export
         b-fo  when (v-cntxt-db-num = 0  and is-finvalue = 'yes' )
         b-sf  when ( is-finvalue = 'yes' )
      WITH FRAME Dialog-Frame.

  VIEW FRAME Dialog-Frame.

define variable  m-i-rc  as widget-handle.
define variable  m-i-rc2  as widget-handle.
create widget-pool "my-pool" persistent no-error .
hide B-close-trn-all in frame {&frame-name} .

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


p-file-label = "Документы Дополнительных расходов".

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

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH buf_add-doc

&scop flt-open-dyn_open-query  FOR EACH buf_add-doc

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name buf_add-doc

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition


&scop flt-open-query p-open-query

&scop flt-open-table-name buf_add-doc

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid doc-rec

&scop flt-open-find-condition p-find-condition

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
        &where-cond = " buf_add-doc.host-code = par-host-code and buf_add-doc.obj-code = p-obj-code and buf_add-doc.obj-type = p-obj-type and buf_add-doc.doc-type = p-doc-type "
        &DYN_where-cond = "substitute(' buf_add-doc.host-code = &2 and buf_add-doc.obj-code = &3 and buf_add-doc.obj-type = &1&4&1  and buf_add-doc.doc-type = &1&5&1 ', ~{&double-quote~}, par-host-code, p-obj-code, p-obj-type, p-doc-type)"
        &use-ind    = " "
        &by         = " " }


    END.
    WHEN "status":U THEN DO:
       ASSIGN frame {&frame-name}:TITLE = title0 + "  ФИРМА: " + buf_clients.obj-name
                                          + " Объект: " +  p-obj-type
                                          + "  " +   string (p-obj-code)
                                          + "   Статус: " +  string(p-status_) .
      { gbl/fltopend.i
        &where-cond = " buf_add-doc.host-code = par-host-code and buf_add-doc.obj-code = p-obj-code and buf_add-doc.obj-type = p-obj-type and buf_add-doc.doc-type = p-doc-type  and buf_add-doc.status_= p-status_ "
        &DYN_where-cond = " substitute(' buf_add-doc.host-code = &2 and buf_add-doc.obj-code = &3 and buf_add-doc.obj-type = &1&4&1  and buf_add-doc.doc-type = &1&5&1 and buf_add-doc.status_ = &1&6&1 ', ~{&double-quote~}, par-host-code, p-obj-code, p-obj-type, p-doc-type, p-status_)"
        &use-ind    = "  "
        &by         = "  " }
    end.
    WHEN "firm" THEN DO:
       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name .
      { gbl/fltopend.i
        &where-cond = " buf_add-doc.host-code = par-host-code and buf_add-doc.doc-type = p-doc-type "
        &DYN_where-cond = " substitute(' buf_add-doc.host-code = &2 and buf_add-doc.doc-type = &1&3&1 ', ~{&double-quote~}, par-host-code, p-doc-type)"
        &use-ind    = " "
        &by         = " " }
    END.

    WHEN "status-firm":U THEN DO:
       ASSIGN frame {&frame-name}:TITLE = title0 + "  ФИРМА: " + buf_clients.obj-name
                                          + "   Статус: " +  string(p-status_) .
      { gbl/fltopend.i
        &where-cond = " buf_add-doc.host-code = par-host-code and buf_add-doc.doc-type = p-doc-type  and buf_add-doc.status_= p-status_ "
        &DYN_where-cond = " substitute(' buf_add-doc.host-code = &2 and buf_add-doc.doc-type = &1&3&1 and buf_add-doc.status_= &1&4&1 ', ~{&double-quote~}, par-host-code, p-doc-type, p-status_)"
        &use-ind    = "  "
        &by         = "  " }
    end.
END CASE.

if not p-open-query and doc-rec <> ? then
   reposition br-docs to recid doc-rec no-error.

if not p-open-query and v-fltopend-rowid[1] <> ?  then do:
  query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
end.
apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame  .
  {&OPEN-QUERY-br-nakl}
  {&SetCursorNo}

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


define variable g-log as log no-undo.
find current buf_add-doc  no-lock   no-error .
if not available buf_add-doc  then return .

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_add-d_deletion':U
  {&cntxt-object}
  buf_add-doc.host-code
  buf_add-doc.obj-type
  buf_add-doc.obj-code
  0
  0
  0
  true
  g-log
}
if not g-log then  return .

define variable v-db-num as integer   no-undo .
define variable varchip-code as character no-undo .
define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf_add-trn for ub.add-trn .
 { gbl/objdbnum.i
   buf_add-doc.obj-type
   buf_add-doc.obj-code
   v-db-num
   }

if v-db-num  <> v-cntxt-db-num then  do:
    message 'Удаление возможно в БД ' v-db-num view-as alert-box information .
    return .
end.

message "Удалить запись ?"
view-as alert-box question
buttons yes-no
update g-log.
if g-log = false then return no-apply.

run waitfram-show ("Ждите! Удаление ДопРасходов и накладных закрытых на факт") .
dtr:
do transaction
   ON ERROR   UNDO dtr, LEAVE
   ON END-KEY UNDO dtr, LEAVE
   ON STOP    UNDO dtr, LEAVE
   :
  find current buf_add-doc  exclusive-lock   no-error .
  if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       ""
       view-as alert-box error
     .
     undo dtr, leave.
  end.

  empty temp-table x_add-trn .
  for each buf_add-trn no-lock where
          buf_add-trn.doc-code = buf_add-doc.doc-code :
      create x_add-trn .
      buffer-copy buf_add-trn to x_add-trn.
  end.
  delete buf_add-doc no-error .
  if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  undo dtr, leave.
  end.
  for each x_add-trn :
      for each buf_trn-doc no-lock where
               buf_trn-doc.doc-code = x_add-trn.trn-doc-code and
               buf_trn-doc.status_  = {&fact} :
              run str/del-doc.p
                ( input  parParentProc,
                  input  buf_trn-doc.doc-code,
                  input  v-cntxt-db-num,
                  input  "del-doc.err",
                  input  ?,
                  input  ?,
                  input  v-cntxt-userid,
                  input  buf_trn-doc.doc-code,
                  input  ?,
                  output varchip-code ) no-error .
                  if error-status :error then do:
                     message
                       vss-workfile vss-revision vss-description skip
                       error-status :get-message(1) skip
                       return-value skip
                       "Ошибки удаления можно посмотреть в файле del-doc.err"
                       view-as alert-box error
                     .
                        undo dtr, leave .
                  end.
      end.
  end.
end.
run waitfram-hide .
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

message "Открыть Документ ДопРасх ?"
view-as alert-box question
buttons yes-no
update g-log.
if g-log = false then return no-apply.
if not available buf_add-doc then return.

if buf_add-doc.status_ = {&g___new} then do:
  message 'Документ ДопРасходов уже открыт' view-as alert-box information .
  return no-apply.
end.
if buf_add-doc.status_ = {&fact} then do:
  message 'Документ уже закрыт на ФАКТ !' view-as alert-box information .
  return no-apply.
end.
define variable o-db-num as integer   no-undo .
{ gbl/objdbnum.i
  buf_add-doc.obj-type
  buf_add-doc.obj-code
  o-db-num
  }
  if o-db-num <> v-cntxt-db-num then do:
    message 'Открыть можно на активной стороне!' view-as alert-box information .
    return no-apply.
  end.

define variable v-i as integer   no-undo .
v-i = 0.

for each ub.add-trn no-lock where
         ub.add-trn.doc-code = buf_add-doc.doc-code ,
    first ub.trn-doc no-lock where ub.trn-doc.doc-code = ub.add-trn.trn-doc-code and
          ub.trn-doc.status_ = {&add-close} :
     v-i = v-i + 1.
end.

if v-i > 0 then do:
  message 'Есть привязанные приходные накладные закрытые на факт ! '
  view-as alert-box information .
  return .
end.


find current buf_add-doc exclusive-lock no-error .
if available buf_add-doc then do:
    buf_add-doc.status_ = {&g___new} .
end.


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
 define variable obj-db-num as integer   no-undo .
  { gbl/objdbnum.i
    v-cntxt-obj-type
    v-cntxt-obj-code
    obj-db-num
    }
    if obj-db-num <> v-cntxt-db-num then do:
      message 'Создание ДопРасхода  только на активной стороне' view-as alert-box information .
      return .
    end.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_add-d_add-def':U
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
  run str/add-docu.w
     (input parparentproc,
      input-output rr ,
      input {&add-def} ,
      input ""  ).
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
  tbl = 'add-doc'
  join-tbl = 'buf_add-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', '№ Документа ДопРасх', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Код фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Дата факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('creid', 'Создал', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name', 'Правил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-close-add-doc Dialog-Frame
PROCEDURE proc-close-add-doc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

if not available buf_add-doc then return.
define variable g-log as logical   no-undo .
g-log = false .
message "Закрыть Документ ДопРасходов ?"
  view-as alert-box question
  buttons yes-no
  update g-log
  .
if g-log = false then return .

if buf_add-doc.status_ = {&add-close} then do:
  g-log = true .
  message
  substitute("При закрытии Документа ДопРасходов &1  на ФАКТ автоматически будут закрыты его ПН . Закрывать ДопРасход ?  " , buf_add-doc.doc-code )
    view-as alert-box question
    buttons yes-no
    update g-log
    .
  if g-log = false then return .

end.
    run str/addclos.p
    ( input Parparentproc,
      recid(buf_add-doc)
    ) .
  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print Dialog-Frame
PROCEDURE proc-print :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable sym1  as char format "X(1)" init ":".
define variable sym2  as char format "X(1)" init ":".
define variable sym3  as char format "X(1)" init ":".
define variable sym4  as char format "X(1)" init ":".
define variable sym5  as char format "X(1)" init ":".
define variable sym6  as char format "X(1)" init ":".
define variable sym7  as char format "X(1)" init ":".
define variable sym8  as char format "X(1)" init ":".
define variable sym9  as char format "X(1)" init ":".
define variable sym10 as char format "X(1)" init ":".
define variable sym11 as char format "X(1)" init ":".
define variable sym12 as char format "X(1)" init ":".

define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable vv-val as character no-undo .
define variable v-i as integer   no-undo .
define variable v-kol as integer   no-undo .
define variable p-delta as decimal format "->,>>>,>>>,>>>,>>9.99"  no-undo .

DEFINE FRAME prt-frame
  {&cop-l2} COLUMN-LABEL {&col-l2} Format "X(6)"
  {&cop-l4} COLUMN-LABEL {&col-l4}
  {&cop-l5} COLUMN-LABEL {&col-l5} FORMAT "99/99/99"
  {&cop-l6} COLUMN-LABEL {&col-l6} FORMAT "99/99/99"
  {&cop-l7} COLUMN-LABEL {&col-l7} format ">>>>9"
  {&cop-l8} COLUMN-LABEL {&col-l8} format "x(3)"
  {&cop-l9} COLUMN-LABEL {&col-l9} format ">>>>>>>>>9.99"
 HEADER  date_string AT 5 format "X(35)"
        string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER( PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
        Line format "X(157)" AT 1
    with width {&DOS_CW_2} down stream-io use-text    .

    Line = fill("-", 157).
    date_string = cur-time-print() .
    run prn-lib-open-stream in this-procedure
    (  input parParentProc
      ,input {&LS_PS_A4}
      ,input yes /*p-is-stream*/
      ,input no /*p-append*/
      ).
    PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title )
    format "x(157)" SKIP(1) .
    FORM HEADER
      Line format "X(177)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .

    FORM with FRAME prt-frame  .
    run waitfram-show in this-procedure ("Ждите печатаю...").

    run OpenBR in this-procedure (yes, no, '':U).
     DO WHILE available buf_add-doc :
       v-kol    = v-kol   + 1 .

        Display STREAM PrnLibStream
             {&cop-l2}
             {&cop-l4}
             {&cop-l5}
             {&cop-l6}
             {&cop-l7}
             {&cop-l8}
             {&cop-l9}
            with FRAME prt-frame .
            DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
            GET next br-docs.
      END.
      UNDERLINE  STREAM PrnLibStream
        {&cop-l2}
        {&cop-l4}
        {&cop-l5}
        {&cop-l6}
        {&cop-l7}
        {&cop-l8}
        {&cop-l9}
    with FRAME prt-frame .

        Display STREAM PrnLibStream
        "Итого"    @  {&cop-l2}
        "док.шт."  @  {&cop-l4}
         v-kol     @  {&cop-l5}

        with FRAME prt-frame .
      DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
      UNDERLINE  STREAM PrnLibStream
        {&cop-l2}
        {&cop-l4}
        {&cop-l5}
        {&cop-l6}
        {&cop-l7}
        {&cop-l8}
        {&cop-l9}
    with FRAME prt-frame .

    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
        input parParentProc
       ,input 8
        ).

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
    (input false     /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and buf_add-doc.doc-code begins &1 "
      , pardoc-code)
    ).
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

ppp =  string( month(pardoc-code)) + "/" +  string( day(pardoc-code)) + "/" +  string( year(pardoc-code)) .
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and buf_add-doc.doc-date = &1 "
      , ppp )
    ) no-error .
    if error-status :error then
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

ppp =  string( month(pardoc-code)) + "/" +  string( day(pardoc-code)) + "/" +  string( year(pardoc-code)) .
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and buf_add-doc.fact-date = &1 "
      , ppp )
    ) no-error .
    if error-status :error then
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