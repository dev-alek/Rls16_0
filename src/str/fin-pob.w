&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список пред.фин.обязательств

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 10/24/03 7:46

*/
define variable  vss-revision    as character no-undo init "$Revision$":U .
define variable  vss-author      as character no-undo init "$Author$":U .
define variable  vss-date        as character no-undo init "$Date$":U .
define variable  vss-workfile    as character no-undo init "$Workfile$":U .
define variable  vss-archive     as character no-undo init "$Archive$":U .
define variable  vss-description as character no-undo init "Список пред.фин.обязательств".
{ cmp/vssrevis.i }
/*кнопки для нажатия*/
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as character   no-undo .
define input parameter par-mode  as character   no-undo .
define input parameter pardoc-rec as recid no-undo.
define input parameter par-host-code like ub.clients.obj-code no-undo.
define input parameter p-doc-type   as character no-undo .
define input parameter p-status_   as character no-undo .
define input parameter p-char      as character no-undo .
define output param rid-list    as  character no-undo . /* список recid'ов выбранных */
define variable g-log as logical no-undo .
define variable doc-rec as recid no-undo .
define variable g#report-num as integer no-undo .

define variable p-base-code as integer no-undo .
define variable l-curr as character no-undo .
define variable p-contr as character no-undo .

/* Local Variable Definitions ---                                       */

{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ str/lib-farh.i }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }


&Scoped-Define main-file ub.fin-ob-before

&scop col-l0   '*'
&scop col-l4  '№ ПФО'
&scop col-l5  'Создан'
&scop col-l6  'Закрыт'
&scop col-l7  'Договор'
&scop col-l8  'Получатель'
&scop col-l9  'Плательщик'
&scop col-l10 'Сумма {&abbr_rub_allshift}'
&scop col-l11 'Вал'
&scop col-l12 'Сумма в вал.док.'
&scop col-l13 '№ РН'
&scop col-l14 'ФинОб'
&scop col-l15 '№ ПН'


&scop cop-l0  mark-string(recid( ub.buf_fin-liab-before), rid-list)
&scop dyn_cop-l0  substitute('dynamic-function(&1mark-string&1, recid(buf_fin-liab-before), &1&2&1)', ~{&double-quote~}, rid-list)
&scop cop-l4  buf_fin-liab-before.prn-doc-code
&scop cop-l5  substring(string(buf_fin-liab-before.doc-date),1,5)
&scop cop-l6  buf_fin-liab-before.fact-date
&scop cop-l7  contract-id(recid( buf_fin-liab-before))
&scop dyn_cop-l7  substitute('dynamic-function(&1contract-id&1, recid(buf_fin-liab-before))', ~{&double-quote~})
&scop cop-l8  (buf_fin-liab-before.receiver-type + ' ' + string(buf_fin-liab-before.receiver-code))
&scop cop-l9  (buf_fin-liab-before.payer-type + ' ' + string(buf_fin-liab-before.payer-code))
&scop cop-l10 buf_fin-liab-before.sum-rubl
&scop cop-l11 val-abbr-type(recid( buf_fin-liab-before))
&scop dyn_cop-l11  substitute('dynamic-function(&1val-abbr-type&1, recid(buf_fin-liab-before))', ~{&double-quote~})
&scop cop-l12 buf_fin-liab-before.sum-doc
&scop cop-l13 buf_fin-liab-before.trn-doc-code
&scop cop-l14 buf_fin-liab-before.doc-code
&scop cop-l15 buf_fin-liab-before.trn-doc-code-orig



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



define variable filter-point as character no-undo init "Список пред.финобязательства" .
define variable filter-point0 as character no-undo init "пред.Фин_обязательства_" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .

define new shared variable br-handle as handle  no-undo .
define new shared variable next-prev as logical no-undo .
DEFINE NEW SHARED BUFFER buf_fin-liab-before FOR {&main-file}.
DEFINE NEW SHARED BUFFER buf_fin-liab        FOR ub.fin-ob.
define buffer find_code for {&main-file} .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_fin-liab-before ub.fin-ob-before

/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs {&cop-l0} {&cop-l4} {&cop-l11} @ l-curr {&cop-l12} {&cop-l13} {&cop-l14} {&cop-l15} {&cop-l5} {&cop-l6} {&cop-l7} @ p-contr {&cop-l8} {&cop-l9} {&cop-l10} buf_fin-liab-before.status_   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs {&cop-l4}   
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH buf_fin-liab-before share-lock
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-liab-before share-lock.
&Scoped-define TABLES-IN-QUERY-BR-docs buf_fin-liab-before
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs buf_fin-liab-before


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-docs}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.fin-ob-before SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.fin-ob-before SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.fin-ob-before
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.fin-ob-before


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-mark B-sel B-sch b-exec-fo B-trn ~
B-trn-2 B-parts B-print B-Help B-lkp B-del B-fo B-Export BR-docs sch-code ~
p-date p-desc-2 p-desc mark-num scr-proc loc_receiver-name loc_sum-doc ~
d-abbr loc_user-name loc_payer-name loc_sum-rubl r-abbr loc_sum-base v-abbr ~
loc_sum-contr v-abbr-contr FILL-IN-1 
&Scoped-Define DISPLAYED-OBJECTS T-paket sch-code p-date p-desc-2 p-desc ~
mark-num scr-proc loc_receiver-name loc_sum-doc d-abbr loc_user-name ~
loc_payer-name loc_sum-rubl r-abbr loc_sum-base v-abbr loc_sum-contr ~
v-abbr-contr FILL-IN-1 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD contract-id Dialog-Frame 
FUNCTION contract-id RETURNS CHARACTER
  ( p-curr-code as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD sel-abbr Dialog-Frame 
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD val-abbr-type Dialog-Frame 
FUNCTION val-abbr-type RETURNS CHARACTER
( p-curr-code as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1 TOOLTIP "Удаление записи"
     BGCOLOR 8 .

DEFINE BUTTON b-exec-fo 
     LABEL "&Генерация" 
     SIZE 10 BY 1 TOOLTIP "Создание фин.обязательств по ПФО"
     BGCOLOR 8 .

DEFINE BUTTON B-exit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Export 
     LABEL "&Экспорт" 
     SIZE 10 BY 1 TOOLTIP "Экспорт в XML"
     BGCOLOR 8 .

DEFINE BUTTON B-fo 
     LABEL "Фин.Об&яз." 
     SIZE 10 BY 1 TOOLTIP "Просмотр фин.обязательства"
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lkp 
     LABEL "&Просмотр" 
     SIZE 10 BY 1 TOOLTIP "Просмотр записи".

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 3 BY 1 TOOLTIP "Отметить строки списка"
     BGCOLOR 8 .

DEFINE BUTTON B-parts 
     LABEL "Па&ртии" 
     SIZE 10 BY 1 TOOLTIP "Просмотр складского документа"
     BGCOLOR 8 .

DEFINE BUTTON B-print 
     LABEL "Пе&чать" 
     SIZE 10 BY 1 TOOLTIP "Печать текущего списка"
     BGCOLOR 8 .

DEFINE BUTTON B-sch 
     LABEL "&Фильтр" 
     SIZE 10 BY 1 TOOLTIP "Фильтрация списка"
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1 TOOLTIP "Выбор отмеченных или текущей записи"
     BGCOLOR 8 .

DEFINE BUTTON B-trn 
     LABEL "Р&Н" 
     SIZE 7 BY 1 TOOLTIP "Просмотр складского документа"
     BGCOLOR 8 .

DEFINE BUTTON B-trn-2 
     LABEL "ПН" 
     SIZE 7 BY 1 TOOLTIP "Просмотр складского документа"
     BGCOLOR 8 .

DEFINE VARIABLE d-abbr AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "ПОИСК ПО" 
      VIEW-AS TEXT 
     SIZE 9 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_payer-name AS CHARACTER FORMAT "X(40)" 
     LABEL "Плательщик" 
      VIEW-AS TEXT 
     SIZE 21.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_receiver-name AS CHARACTER FORMAT "X(40)" 
     LABEL "Получатель" 
      VIEW-AS TEXT 
     SIZE 21.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc_sum-base AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0 
     LABEL "Сумма б.в." 
      VIEW-AS TEXT 
     SIZE 17.5 BY .67 NO-UNDO.

DEFINE VARIABLE loc_sum-contr AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0 
     LABEL "Сумма дог." 
      VIEW-AS TEXT 
     SIZE 17.5 BY .67 TOOLTIP "Сумма в валюте договора" NO-UNDO.

DEFINE VARIABLE loc_sum-doc AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0 
     LABEL "Сумма док." 
      VIEW-AS TEXT 
     SIZE 17.5 BY .67 NO-UNDO.

DEFINE VARIABLE loc_sum-rubl AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0 
     LABEL "Сумма abbr_rub." 
      VIEW-AS TEXT 
     SIZE 17.5 BY .67 NO-UNDO.

DEFINE VARIABLE loc_user-name AS CHARACTER FORMAT "X(10)" 
     LABEL "Создал" 
      VIEW-AS TEXT 
     SIZE 12.88 BY .67 NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE p-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата" 
     VIEW-AS FILL-IN 
     SIZE 12.75 BY 1 TOOLTIP "Поиск по дате создания пред.фин.об. Поиск первой записи - <ВВОД>;  поиск следующей - <CTRL-J>"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE p-desc AS CHARACTER FORMAT "X(80)":U 
     LABEL "№ договора" 
     VIEW-AS FILL-IN 
     SIZE 12.75 BY 1 TOOLTIP "Поиск по № договора  Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE p-desc-2 AS CHARACTER FORMAT "X(80)":U 
     LABEL "№ РН" 
     VIEW-AS FILL-IN 
     SIZE 12.75 BY 1 TOOLTIP "Поиск по № РН  Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE r-abbr AS CHARACTER FORMAT "X(256)":U INITIAL "abbr_rub_allshift" 
      VIEW-AS TEXT 
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(12)":U 
     LABEL "№ ПредФинОбяз" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 TOOLTIP "Поиск по номеру Поиск первой записи - <ВВОД>; поиск следующей -  <CTRL-J>"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE scr-proc AS DECIMAL FORMAT "->>>>9.99%":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 9.5 BY .67 TOOLTIP "Процент суммы ПФО к сумме ПН"
     BGCOLOR 4 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-abbr AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-abbr-contr AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE T-paket AS LOGICAL INITIAL no 
     LABEL "П&акетный режим" 
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY .83 TOOLTIP "Работа с выделенным списком пред.финобязательств" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-docs FOR 
      buf_fin-liab-before SCROLLING.

DEFINE QUERY Dialog-Frame FOR 
      ub.fin-ob-before SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs DISPLAY
      {&cop-l0}    COLUMN-LABEL {&col-l0}          FORMAT "x(1)"
     {&cop-l4}    COLUMN-LABEL {&col-l4}          Format "x(10)"
     {&cop-l11}  @ l-curr  COLUMN-LABEL {&col-l11}         Format "x(3)"
     {&cop-l12}   COLUMN-LABEL {&col-l12}
     {&cop-l13}   COLUMN-LABEL {&col-l13}         Format "x(14)"
     {&cop-l14}   COLUMN-LABEL {&col-l14}         Format "x(14)"
     {&cop-l15}   COLUMN-LABEL {&col-l15}         Format "x(14)"
     {&cop-l5}    COLUMN-LABEL {&col-l5}          format "x(5)"
     {&cop-l6}    COLUMN-LABEL {&col-l6}          format "99/99/99"
     {&cop-l7}  @ p-contr  COLUMN-LABEL {&col-l7}          Format "x(16)"
     {&cop-l8}    COLUMN-LABEL {&col-l8}          Format "x(10)"
     {&cop-l9}    COLUMN-LABEL {&col-l9}          Format "x(10)"
     {&cop-l10}   COLUMN-LABEL {&col-l10}
       buf_fin-liab-before.status_
      enable {&cop-l4}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 93.75 BY 15.79.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-sch AT ROW 1 COL 31
     b-exec-fo AT ROW 1 COL 41
     B-trn AT ROW 1 COL 51
     B-trn-2 AT ROW 1 COL 58
     B-parts AT ROW 1 COL 65.13
     B-print AT ROW 1 COL 75.13
     B-Help AT ROW 1 COL 85.13
     B-lkp AT ROW 2.13 COL 1
     B-del AT ROW 2.13 COL 11
     B-fo AT ROW 2.13 COL 21
     B-Export AT ROW 2.13 COL 31
     BR-docs AT ROW 3.25 COL 1.25
     T-paket AT ROW 19.96 COL 74.13
     sch-code AT ROW 22.5 COL 1.5
     p-date AT ROW 22.5 COL 31.5
     p-desc-2 AT ROW 22.5 COL 51
     p-desc AT ROW 22.5 COL 70.5
     mark-num AT ROW 1 COL 14.88 NO-LABEL
     scr-proc AT ROW 2.25 COL 83.5 COLON-ALIGNED NO-LABEL
     loc_receiver-name AT ROW 19.13 COL 1.88
     loc_sum-doc AT ROW 19.13 COL 45.25 COLON-ALIGNED
     d-abbr AT ROW 19.13 COL 63.63 COLON-ALIGNED NO-LABEL
     loc_user-name AT ROW 19.13 COL 79.88 COLON-ALIGNED
     loc_payer-name AT ROW 19.96 COL 1.88
     loc_sum-rubl AT ROW 19.96 COL 45.25 COLON-ALIGNED
     r-abbr AT ROW 19.96 COL 63.63 COLON-ALIGNED NO-LABEL
     loc_sum-base AT ROW 20.79 COL 45.25 COLON-ALIGNED
     v-abbr AT ROW 20.79 COL 63.63 COLON-ALIGNED NO-LABEL
     loc_sum-contr AT ROW 21.58 COL 45.25 COLON-ALIGNED
     v-abbr-contr AT ROW 21.58 COL 63.63 COLON-ALIGNED NO-LABEL
     FILL-IN-1 AT ROW 21.88 COL 1 NO-LABEL
     SPACE(85.62) SKIP(1.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "ПредФинОбязательства"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-docs B-Export Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BR-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN loc_payer-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN loc_receiver-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN p-date IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN p-desc IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN p-desc-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN sch-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR TOGGLE-BOX T-paket IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       T-paket:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docs
/* Query rebuild information for BROWSE BR-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-liab-before share-lock.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-docs */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.fin-ob-before"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* ПредФинОбязательства */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:

if not available buf_fin-liab-before then return .

/* Право на удаление */
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_deletion':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
if not g-log then  return .
  else do:
      message "Удалить запись ?"
      view-as alert-box question
      buttons yes-no
      update g-log.
      if g-log = false then return no-apply.
  end.

  if  buf_fin-liab-before.status_ = {&fin-fact} then do:
      message "ПредФинОбязательство в статусе ФАКТ не может быть удалено !!!"
      view-as alert-box information .
      return no-apply.
  end.
  find current buf_fin-liab-before  exclusive-lock  no-error .
  if available buf_fin-liab-before then do:
    delete buf_fin-liab-before .
    run openbr in this-procedure (yes, no, '':u).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exec-fo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exec-fo Dialog-Frame
ON CHOOSE OF b-exec-fo IN FRAME Dialog-Frame /* Генерация */
DO:
define variable par-text as character no-undo .
  run str/gen-bfl.p (
      input parParentProc,
      input par-host-code,
      input true ,
      output par-text
      ).
  run openbr in this-procedure (yes, no, '':u).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Export Dialog-Frame
ON CHOOSE OF B-Export IN FRAME Dialog-Frame /* Экспорт */
DO:
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_export':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
if not g-log then  return .

  run proc-b-exp in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-fo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-fo Dialog-Frame
ON CHOOSE OF B-fo IN FRAME Dialog-Frame /* Фин.Обяз. */
DO:
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_lookup':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
if not g-log then  return .
define variable rr as recid no-undo .
define variable v-doc-type like ub.fin-ob.doc-type  no-undo .
define variable v-status_  like ub.fin-ob.status_   no-undo .
define buffer buf_fin-ob for ub.fin-ob .
find first buf_fin-ob no-lock where buf_fin-ob.doc-code = buf_fin-liab-before.doc-code no-error .

    if available buf_fin-ob then do:
        rr = recid( buf_fin-ob ).
        find first buf_fin-liab no-lock where recid (buf_fin-liab) = rr no-error .
        v-doc-type = buf_fin-ob.doc-type .
        v-status_  = buf_fin-ob.status_  .
        br-handle = ? .
        next-prev = ?.
        run str/fi-liabi.w ( parParentProc, {&lookup} , input-output rr , input par-host-code  , input v-doc-type, input v-status_).
        br-handle = ? .
     end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_lookup':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
if not g-log then  return .
define variable rr as recid no-undo .
    if available buf_fin-liab-before then do:
        rr = recid( buf_fin-liab-before ).
        p-doc-type = buf_fin-liab-before.doc-type .
        p-status_  = buf_fin-liab-before.status_  .

      br-handle = {&browse-name}:handle in frame {&frame-name} .
      next-prev = no.
      do while next-prev <> ?:
        if not available buf_fin-liab-before then do:
          message "Неправильный выбор документа.".
          return no-apply.
        end.

        run str/fi-liabb.w ( parParentProc, {&lookup} , input-output rr , input par-host-code  , input p-doc-type, input p-status_).
        if br-handle = ? then reposition {&browse-name} to recid rr no-error.
      end.
     end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
      if available buf_fin-liab-before then do:
        { gbl/markstrn.i buf_fin-liab-before rid-list }
        g-log = br-docs:refresh() .

        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = br-docs:select-next-row ().
            apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
        end.

        if num-entries( rid-list ) = 0
        then
            hide mark-num in frame {&frame-name}.
        else do:
            mark-num:screen-value in frame {&frame-name}  = string (num-entries( rid-list )) .
            enable mark-num with frame {&frame-name}.
            end.
    end.
    apply "entry" to br-docs in frame {&frame-name}.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-parts Dialog-Frame
ON CHOOSE OF B-parts IN FRAME Dialog-Frame /* Партии */
DO:
    if not available buf_fin-liab-before then return .
    run str/fi-parts.w
      (input parParentProc ,
       input buf_fin-liab-before.before-code ,
       input par-host-code  ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run print-proc in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available buf_fin-liab-before ) AND ( rid-list = "" ) then
    rid-list = string( recid( buf_fin-liab-before ) ) .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-trn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-trn Dialog-Frame
ON CHOOSE OF B-trn IN FRAME Dialog-Frame /* РН */
DO:
define buffer buf_trn-doc for ub.trn-doc.
define buffer buff_fin-ob-trn for ub.fin-ob-trn.

define variable glog as logical no-undo .

if not available buf_fin-liab-before then return .

if  buf_fin-liab-before.trn-doc-code <> ""
  and buf_fin-liab-before.trn-doc-code <> ?
  then do:
   find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_fin-liab-before.trn-doc-code no-error .
   if available buf_trn-doc then do:
      run str/fishdoc.p (  ParParentProc,
                      par-host-code   ,
                      buf_trn-doc.obj-type ,
                      buf_trn-doc.obj-code ,
                      buf_fin-liab-before.trn-doc-code ,
                      ? ) .
      end.
  end.
  else do:
      find first buff_fin-ob-trn no-lock where buff_fin-ob-trn.doc-code = buf_fin-liab-before.before-code     no-error .
      find first buf_trn-doc     no-lock where buf_trn-doc.doc-code     = buff_fin-ob-trn.trn-doc-code no-error .
      if available buff_fin-ob-trn then do:
              run str/fishdoc.p ( ParParentProc,
                  par-host-code        ,
                  buf_trn-doc.obj-type ,
                  buf_trn-doc.obj-code ,
                  buff_fin-ob-trn.trn-doc-code ,
                  ? ) .
      end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-trn-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-trn-2 Dialog-Frame
ON CHOOSE OF B-trn-2 IN FRAME Dialog-Frame /* ПН */
DO:
define buffer buf_trn-doc for ub.trn-doc.
define variable glog as logical no-undo .

if not available buf_fin-liab-before then return .

if  buf_fin-liab-before.trn-doc-code-orig <> ""
  and buf_fin-liab-before.trn-doc-code-orig <> ?
  then do:
   find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_fin-liab-before.trn-doc-code-orig no-error .
   if available buf_trn-doc then do:
      run str/fishdoc.p (  ParParentProc,
                 par-host-code ,
                 buf_trn-doc.obj-type,
                 buf_trn-doc.obj-code,
                 buf_fin-liab-before.trn-doc-code-orig , ? ) .
      end.
  end.
  else do:
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON DELETE-CHARACTER OF BR-docs IN FRAME Dialog-Frame
DO:
   if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON INSERT-MODE OF BR-docs IN FRAME Dialog-Frame
DO:
    if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
    else do:
      if b-sel:sensitive in frame {&frame-name} then
      APPLY "CHOOSE" to b-sel.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON RETURN OF BR-docs IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF {&self-name} IN FRAME {&frame-name}
DO:
      if b-sel:sensitive in frame {&frame-name}  = yes then
        apply "choose" to b-sel in frame {&frame-name}.
    else
        apply "choose" to B-lkp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
if available buf_fin-liab-before then do:
    assign
    loc_receiver-name  = buf_fin-liab-before.receiver-name
    loc_payer-name        = buf_fin-liab-before.payer-name
    loc_sum-base  = buf_fin-liab-before.sum-base
    loc_sum-doc   = buf_fin-liab-before.sum-doc
    loc_sum-rubl  = buf_fin-liab-before.sum-rubl
    loc_sum-contr  =  buf_fin-liab-before.sum-contract
    d-abbr        = sel-abbr(buf_fin-liab-before.curr-code)
    v-abbr        = sel-abbr(p-base-code)
    v-abbr-contr    = sel-abbr(buf_fin-liab-before.contract-curr)
    loc_user-name = buf_fin-liab-before.user-name-doc
  .
  { gbl/usrfulnm.i
  buf_fin-liab-before.user-name-doc
  loc_user-name
  }

end.

else
 assign
   loc_receiver-name  = ""
   loc_payer-name        = ""
   loc_sum-base            = 0
   loc_sum-doc             = 0
   loc_sum-rubl            = 0
   loc_user-name           = ""
   d-abbr                         = ""
   loc_sum-contr            = 0
      v-abbr-contr  = ""
    .

display
  loc_receiver-name
  loc_payer-name
  loc_sum-base
  loc_sum-doc
  loc_sum-rubl
  loc_sum-contr
  r-abbr
  v-abbr
  d-abbr
  loc_user-name
  v-abbr-contr
  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME p-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL p-date Dialog-Frame
ON LEAVE OF p-date IN FRAME Dialog-Frame /* Дата */
DO:
END.

ON CTRL-J OF p-date IN FRAME Dialog-Frame
DO:
assign p-date no-error .
  if error-status:error then return no-apply.
      run proc-find-date in this-procedure(yes, p-date) no-error.
      if error-status:error then return no-apply.

END.

ON RETURN OF p-date IN FRAME Dialog-Frame
DO:
assign p-date no-error .
if error-status:error then return no-apply.
  run proc-find-date in this-procedure(no, p-date) no-error.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME p-desc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL p-desc Dialog-Frame
ON LEAVE OF p-desc IN FRAME Dialog-Frame /* № договора */
DO:
END.

ON CTRL-J OF p-desc IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-desc in this-procedure(yes, input frame {&frame-name} p-desc) no-error.
    if error-status:error then return no-apply.

END.

ON RETURN OF p-desc IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-desc in this-procedure(no, input frame {&frame-name} p-desc) no-error.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME p-desc-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL p-desc-2 Dialog-Frame
ON LEAVE OF p-desc-2 IN FRAME Dialog-Frame /* № РН */
DO:
END.

ON CTRL-J OF p-desc-2 IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-desc-2 in this-procedure(yes, input frame {&frame-name} p-desc-2) no-error.
    if error-status:error then return no-apply.

END.

ON RETURN OF p-desc-2 IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-desc-2 in this-procedure(no, input frame {&frame-name} p-desc-2) no-error.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* № ПредФинОбяз */
DO:
  run proc-find-code in this-procedure(no, input frame {&frame-name} sch-code) no-error.
  return no-apply.
END.

ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-code in this-procedure(yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-paket
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-paket Dialog-Frame
ON VALUE-CHANGED OF T-paket IN FRAME Dialog-Frame /* Пакетный режим */
DO:
  assign T-paket.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

{ gbl/brwrepos.i
  &line-num=8
}



/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/ed_date.i p-date }
{ gbl/mv-clmn.i
 &ext-col = 13
 &start-column = 3
 &frame-name = {&frame-name}
 &browse-name = {&browse-name}
}

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&main-file}"
  &label-clmn_1     =   "{&col-l0}"
  &label-clmn_2     =   "{&col-l4}"
  &label-clmn_3     =   "{&col-l5}"
  &label-clmn_4     =   "{&col-l6}"
  &label-clmn_5     =   "{&col-l7}"
  &label-clmn_6     =   "{&col-l8}"
  &label-clmn_7     =   "{&col-l9}"
  &label-clmn_8     =   "{&col-l10}"
  &label-clmn_9     =   "{&col-l11}"
  &label-clmn_10    =   "{&col-l12}"
  &label-clmn_11    =   "{&col-l13}"
  &label-clmn_12    =   "{&col-l14}"
  &label-clmn_13    =   "{&col-l15}"
  &sort-clmn_1    =   "{&cop-l0}"
  &dyn_sort-clmn_1  =   "{&dyn_cop-l0}"
  &sort-clmn_2    =   "{&cop-l4}"
  &sort-clmn_3    =   "{&cop-l5}"
  &sort-clmn_4    =   "{&cop-l6}"
  &sort-clmn_5    =   "{&cop-l7}"
  &dyn_sort-clmn_5    =   "{&dyn_cop-l7}"
  &sort-clmn_6    =   "{&cop-l8}"
  &sort-clmn_7    =   "{&cop-l9}"
  &sort-clmn_8    =   "{&cop-l10}"
  &sort-clmn_9    =   "{&cop-l11}"
  &dyn_sort-clmn_9    =   "{&dyn_cop-l11}"
  &sort-clmn_10   =   "{&cop-l12}"
  &sort-clmn_11    =  "{&cop-l13}"
  &sort-clmn_12    =  "{&cop-l14}"
  &sort-clmn_13    =  "{&cop-l15}"

&open-query     = "run OpenBr(yes, no, '':U)."
&open-query-otherwise = "run OpenBr(yes, no, '':U)."
&sort-column-name     = "sort-column-name"
&re-move-clmn         = "yes"
&mv-brw-default       = "yes" }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
/* зацикливание формы */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }
/* Права на просмотр списка */
define variable v-right-supp as logical no-undo .
v-right-supp = true .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-supp':U
    {&cntxt-firm}
    par-host-code
    ''
    0
    0
    0
    0
    true
    v-right-supp
  }
 if v-right-supp = false then return .

{&cop-l4}:read-only in browse {&browse-name} = true .

/* Нaзвание таблицы */
define variable p-file-label as character no-undo .

p-file-label =  "Финансовые обязательства".
r-abbr =  "{&abbr_rub_allshift}".

define buffer buf_clients for  ub.clients .
CASE par-mode:
    WHEN {&company} THEN DO:
      find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
      if not available buf_clients then  return .
    END.
    WHEN "doc-type":U THEN DO:
      find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
      if not available buf_clients then  return .
    END.
    WHEN "status":U THEN DO:
      find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
      if not available buf_clients then  return .
    END.
    WHEN "fin-ob":U THEN DO:
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - par-mode=" par-mode
      view-as alert-box ERROR.
      return.
    end.
  end CASE.
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
  run calc-proc.
  run my-enable_ui.
  run openbr in this-procedure (yes, no, '':u).
  hide mark-num in frame {&frame-name} .
  if pardoc-rec <> ? then
  reposition br-docs to recid doc-rec no-error.
  apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-docs.

END.
run disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-proc Dialog-Frame 
PROCEDURE calc-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define buffer buf1_fin-ob for ub.fin-ob.
define buffer buf1_fin-ob-before for ub.fin-ob-before.
define variable v-PFO-sum as decimal no-undo init 0.
define variable v-FO-sum as decimal no-undo init 0 .

find first buf1_fin-ob no-lock  where
           buf1_fin-ob.host-code = par-host-code and
           buf1_fin-ob.doc-code  =  p-char
           no-error .
if error-status :error then return .
v-FO-sum = abs(buf1_fin-ob.sum-doc) .

for each buf1_fin-ob-before no-lock where
    buf1_fin-ob-before.doc-code = p-char  and
    buf1_fin-ob-before.host-code = par-host-code
    on error undo, return error :
    v-PFO-sum = v-PFO-sum + buf1_fin-ob-before.sum-doc .
end. /* for each */

scr-proc =  100 * v-PFO-sum / v-FO-sum.

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY T-paket sch-code p-date p-desc-2 p-desc mark-num scr-proc 
          loc_receiver-name loc_sum-doc d-abbr loc_user-name loc_payer-name 
          loc_sum-rubl r-abbr loc_sum-base v-abbr loc_sum-contr v-abbr-contr 
          FILL-IN-1 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-mark B-sel B-sch b-exec-fo B-trn B-trn-2 B-parts B-print 
         B-Help B-lkp B-del B-fo B-Export BR-docs sch-code p-date p-desc-2 
         p-desc mark-num scr-proc loc_receiver-name loc_sum-doc d-abbr 
         loc_user-name loc_payer-name loc_sum-rubl r-abbr loc_sum-base v-abbr 
         loc_sum-contr v-abbr-contr FILL-IN-1 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable_UI Dialog-Frame 
PROCEDURE my-enable_UI :
{ gbl/basecode.i par-host-code p-base-code }
assign
loc_sum-rubl:label in frame {&frame-name} = "Сумма {&abbr_rub}."
.
DISPLAY sch-code p-desc p-desc-2  p-date mark-num FILL-IN-1
      scr-proc when par-mode = "fin-ob"
      WITH FRAME Dialog-Frame.
  ENABLE B-exit
         B-lkp
         b-exec-fo
         b-trn
         B-trn-2
         b-parts
         B-sch
         B-print
         B-Help
         b-sel       when LOOKUP("b-sel":U,  bttns) > 0
         b-mark      when LOOKUP("b-mark":U, bttns) > 0
         b-del       when LOOKUP("b-del":U,  bttns) > 0
         b-fo
         b-export
          BR-docs sch-code p-desc p-desc-2 p-date  mark-num
         T-paket
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if  par-mode <> "fin-ob" then
     hide  scr-proc in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable  l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define buffer buff_contract for ub.contract.
define variable loc_contract-code as character no-undo .


title0 = caps( "ПредФинОбязательства" ) + {&space-char}.

{&SetCursorWait}
define variable  sort-column-phrase as character no-undo .

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

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH buf_fin-liab-before

&scop flt-open-dyn_open-query  FOR EACH buf_fin-liab-before

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name buf_fin-liab-before

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

/* indexed-reposition */

&scop flt-open-query p-open-query

&scop flt-open-table-name buf_fin-liab-before

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-def define buffer buf_fin-liab-before for {&main-file}.

&scop flt-open-debug-file

&scop flt-open-waitfram  true

define variable l-open-query as logical   no-undo .
       find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
       if not available buf_clients then return .
       filter-point = filter-point0 + par-mode.


  CASE par-mode :
    WHEN {&company} THEN DO:
       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " " +  string(par-host-code).
      { gbl/fltopend.i
        &where-cond = " buf_fin-liab-before.host-code = par-host-code   "
        &dyn_where-cond = "substitute(' buf_fin-liab-before.host-code =   &1 ' , par-host-code )"
        &use-ind    = " USE-INDEX by_date "
        &by         = "  " }
    END.

    WHEN "doc-type":U THEN DO:
       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " " +  string(par-host-code)
                                          + " Тип: " +  string(p-doc-type) .
      { gbl/fltopend.i
        &where-cond = " buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-type = p-doc-type "
        &dyn_where-cond = "substitute(' buf_fin-liab-before.host-code = &1 and buf_fin-liab-before.doc-type = &3&2&3 ' , par-host-code , p-doc-type , ~{&double-quote~}  )"
        &use-ind    = " USE-INDEX by_date "
        &by         = "  " }

        /* ИЗМЕНИТЬ ИНДЕКС !!! */
    END.

    WHEN "status":U THEN DO:
       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " " +  string(par-host-code)
                                          + " Тип: " +  string(p-doc-type)
                                          + " Статус: " +  string(p-status_) .
      { gbl/fltopend.i
        &where-cond = " buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-type = p-doc-type  and buf_fin-liab-before.status_= p-status_"
        &dyn_where-cond = "substitute(' buf_fin-liab-before.host-code = &1 and buf_fin-liab-before.doc-type = &3&2&3 and buf_fin-liab-before.status_ = &3&4&3  ' , par-host-code , p-doc-type , ~{&double-quote~} , p-status_ )"
        &use-ind    = " USE-INDEX by_date "
        &by         = "  " }

        /* ИЗМЕНИТЬ ИНДЕКС !!! */
    END.
    WHEN "fin-ob":U THEN DO:


       ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " " +  string(par-host-code)
                                          + " по Фин.обязательству: " +  p-char   .
      { gbl/fltopend.i
        &where-cond = " buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-code = p-char"
        &dyn_where-cond = "substitute(' buf_fin-liab-before.host-code = &1 and buf_fin-liab-before.doc-code = &3&2&3 ' , par-host-code , p-char , ~{&double-quote~}  )"
        &use-ind    = " USE-INDEX by_fo "
        &by         = "  " }

        /* ИЗМЕНИТЬ ИНДЕКС !!! */
    END.



END CASE.
if not p-open-query then
REPOSITION br-docs to recid doc-rec No-ERROR.
if error-status :error then return error .
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

{&SetCursorNo}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-proc Dialog-Frame 
PROCEDURE print-proc :
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_print':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
if not g-log then  return .

define variable  sym1  as character format "X(1)" init ":".
define variable  sym2  as character format "X(1)" init ":".
define variable  sym3  as character format "X(1)" init ":".
define variable  sym4  as character format "X(1)" init ":".
define variable  sym5  as character format "X(1)" init ":".
define variable  sym6  as character format "X(1)" init ":".
define variable  sym7  as character format "X(1)" init ":".
define variable  sym8  as character format "X(1)" init ":".
define variable  sym9  as character format "X(1)" init ":".
define variable  sym10 as character format "X(1)" init ":".
define variable  sym11 as character format "X(1)" init ":".
define variable  sym12 as character format "X(1)" init ":".

define variable  date_string     as      character    no-undo.
define variable  Line                as      character    no-undo.
define variable  for-time as char.


DEFINE FRAME prt-frame
     {&cop-l4}                  column-label {&col-l4} Format "x(10)"      space(0)     sym3                      column-label "_"       format "X(1)"       space(0)
     buf_fin-liab-before.doc-date      column-label {&col-l5} format  "99/99/99"  space(0)     sym4                      column-label "_"       format "X(1)"       space(0)
     {&cop-l6}                  column-label {&col-l6} format "99/99/99"   space(0)     sym5                      column-label "_"       format "X(1)"       space(0)
     p-contr                    column-label {&col-l7}                     space(0)     sym6                      column-label "_"       format "X(1)"       space(0)
     buf_fin-liab-before.receiver-name column-label {&col-l8} Format "x(10)"      space(0)        sym7                      column-label "_"       format "X(1)"       space(0)
     buf_fin-liab-before.payer-name    column-label {&col-l9} Format "x(10)"      space(0)     sym8                      column-label "_"       format "X(1)"       space(0)
     {&cop-l10}                  column-label {&col-l10}                space(0)     sym9                      column-label "_"       format "X(1)"       space(0)
     l-curr                     column-label {&col-l11} Format "x(3)"      space(0)   sym10                     column-label "_"       format "X(1)"       space(0)
     {&cop-l12}                 column-label {&col-l12}                    space(0)     sym11                     column-label "_"       format "X(1)"       space(0)
     {&cop-l13}                 column-label {&col-l13} Format "x(14)"      space(0)
        HEADER  date_string AT 5 format "X(35)"
                    string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER( PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
                    Line format "X(116)" AT 1
    with width {&DOS_CW_2} down stream-io use-text    .

    Line = fill("-", 116).
    date_string = cur-time-print() .
    run prn-lib-open-stream  in this-procedure (
       input parParentProc
      ,input {&LS_PS_A4}
      ,input yes /*p-is-stream*/
      ,input no /*p-append*/
      ).
    PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title )
    format "x(116)" SKIP(1) .
    FORM HEADER
            Line format "X(177)" AT 1 SKIP
            "Продолжение - на следующей странице" AT 30 SKIP
            with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .

    FORM with FRAME prt-frame  .
    run waitfram-show in this-procedure ("Ждите...").

    run OpenBR in this-procedure (yes, no, '':U).
     DO WHILE available buf_fin-liab-before :
        Display STREAM PrnLibStream
             {&cop-l4}
             sym3
             buf_fin-liab-before.doc-date
             sym4
             {&cop-l6}
             sym5
             {&cop-l7} @ p-contr
             sym6
             buf_fin-liab-before.receiver-name
             sym7
             buf_fin-liab-before.payer-name
             sym8
             {&cop-l10}
             sym9
             val-abbr-type(recid( buf_fin-liab-before)) @ l-curr
             sym10
             {&cop-l12}
             sym11
             {&cop-l13}

            with FRAME prt-frame .
            DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
            GET next br-docs.
      END.
      UNDERLINE  STREAM PrnLibStream
             {&cop-l4}
             sym3
             buf_fin-liab-before.doc-date
             sym4
             {&cop-l6}
             sym5
             p-contr
             sym6
             buf_fin-liab-before.receiver-name
             sym7
             buf_fin-liab-before.payer-name
             sym8
             {&cop-l10}
             sym9
             l-curr
             sym10
             {&cop-l12}
             sym11
             {&cop-l13}
    with FRAME prt-frame .
    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    reposition br-docs  to row 1 no-error .
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
        input parParentProc
       ,input 8
        ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-exp Dialog-Frame 
PROCEDURE proc-b-exp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable varxmldocfl      as character no-undo.
define variable varxmldocfl-type as character no-undo.
define variable v-file-name as character no-undo .
define variable for-dir as character no-undo .
define variable accum-count as integer no-undo init 0.
define variable accum-count-ok as integer no-undo init 0 .
define variable loclog as logical no-undo .
define variable ii as integer no-undo .
define variable ii0 as integer no-undo .

define buffer buf_fin-ob-before for ub.fin-ob-before.


if not available buf_fin-liab-before then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.

    assign
    v-file-name =  ?
    .
    run bge/xmlfob.p (input buf_fin-liab-before.host-code, buf_fin-liab-before.before-code, input-output v-file-name, yes, yes) no-error .
if error-status:ERROR then do:
  message
  "Ошибка при выгрузке ФО в XML-формате" skip

  error-status :get-message(1)
  view-as alert-box .
   return error .
end.

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
       message "ФО выгружены в файл " v-file-name view-as alert-box.
    else
      message "ФО выгружен в файл " v-file-name view-as alert-box.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame 
PROCEDURE proc-b-sch :
assign
  tbl = '{&main-file}'
  join-tbl = 'buf_fin-liab-before'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('before-code', '№ ПФО', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-code', 'Вн.№ фин.об', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('trn-doc-code', '№ РН', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('trn-doc-code-orig', '№ ПН', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('contract-code', 'Вн.№ договора', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-doc', 'Создал', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', 'Дата документа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Дата факта', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('curr-code', 'Валюта', 'curr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*
curr-code
fact-date
pay-date
payer-bank-name
payer-bik
payer-c-schet

payer-code
payer-inn
payer-kpp
payer-name
payer-okpo
payer-r-schet
payer-type
receiver-bank-name
receiver-bik
receiver-c-schet
receiver-code
receiver-inn
receiver-kpp
receiver-name
receiver-okpo
receiver-r-schet
receiver-type
sum-base
sum-contract
sum-doc
sum-rubl
trn-doc-code
user-name-doc
user-name-fact
user-name-pay
*/

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run openbr in this-procedure (yes, no, '':u).
END. /* Filter-Block */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame 
PROCEDURE proc-find-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as character no-undo.
display "" @ p-desc with frame {&frame-name}.
display "" @ p-desc-2 with frame {&frame-name}.
display "" @ p-date with frame {&frame-name}.

assign
  pardoc-code = {&double-quote} + pardoc-code + {&double-quote} .

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and buf_fin-liab-before.prn-doc-code = &1 "
      , pardoc-code )
    ) no-error .
    if error-status :error or return-value = ? then
       message "Не найдено ни одной записи !" view-as alert-box .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-date Dialog-Frame 
PROCEDURE proc-find-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as date no-undo.
define variable ppp as character no-undo .

display "" @ p-desc with frame {&frame-name}.
display "" @ p-desc-2 with frame {&frame-name}.
display "" @ sch-code with frame {&frame-name}.

ppp =  string( day(pardoc-code)) + "/" +  string( month(pardoc-code)) + "/" +  string( year(pardoc-code)) .
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and buf_fin-liab-before.doc-date = &1 "
      , ppp )
    )  no-error .
    if error-status :error or return-value = ? then
       message "За эту дату не найдено ни одной записи !" view-as alert-box .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-desc Dialog-Frame 
PROCEDURE proc-find-desc :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as character no-undo.
define variable pp as integer no-undo .
define buffer b_contract for ub.contract .
display "" @ sch-code with frame {&frame-name}.
display "" @ p-date with frame {&frame-name}.
display "" @ p-desc-2 with frame {&frame-name}.
if  par-next = true then
    find next b_contract no-lock where b_contract.host-code = par-host-code and b_contract.contract-prn-code = pardoc-code use-index num no-error .
else
  find first b_contract no-lock where b_contract.host-code = par-host-code and b_contract.contract-prn-code = pardoc-code  use-index num no-error .

if available b_contract
then do:
pp = b_contract.contract-code.
    run OpenBr in this-procedure
        (input false     /* p-open-query */
        ,input par-next  /* p-find-next  */
        ,input substitute("and buf_fin-liab-before.contract-code = &1 "
          , pp)
        ) no-error .
    if error-status :error or return-value = ? then
       message "Не найдено ни одной записи !" view-as alert-box .


end.
else do:
message "Договор с таким номером не найден !!!" .
apply "entry":u to p-desc in frame {&frame-name} .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-desc-2 Dialog-Frame 
PROCEDURE proc-find-desc-2 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

define input parameter par-next as logical no-undo.
define input parameter pardoc-code as character no-undo.
define variable pp as integer no-undo .
define buffer b_contract for ub.contract .
display "" @ sch-code with frame {&frame-name}.
display "" @ p-date with frame {&frame-name}.
display "" @ p-desc with frame {&frame-name}.


run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and buf_fin-liab-before.trn-doc-code begins '&1' "
      , pardoc-code)
    ) no-error .

if error-status :error or return-value = ? then do:
    message "Запись не найдена !!!" .
    apply "entry":u to p-desc-2 in frame {&frame-name} .
end.


  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-filter-name Dialog-Frame 
PROCEDURE set-filter-name :
define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = frame {&frame-name}:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.

  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION contract-id Dialog-Frame 
FUNCTION contract-id RETURNS CHARACTER
( input p-rec as recid ) :
define  BUFFER loc-fin-liab FOR ub.fin-ob-before .
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error .
if error-status :error then return '' .

  define variable rr as character no-undo .
  define buffer buf-f_contract for ub.contract.


  find first buf-f_contract no-lock where  buf-f_contract.host-code      = par-host-code  and
                                          buf-f_contract.contract-code  = loc-fin-liab.contract-code  no-error.

  if available buf-f_contract then   rr = buf-f_contract.contract-prn-code.
     else rr = "".
  RETURN rr.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sel-abbr Dialog-Frame 
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int ) :
  define variable rr as character no-undo .
  find first ub.currency no-lock where  ub.currency.curr-code  = p-curr-code no-error.
  rr = ub.currency.curr-abbr .
  RETURN rr.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION val-abbr-type Dialog-Frame 
FUNCTION val-abbr-type RETURNS CHARACTER
( input p-rec as recid ) :
define  BUFFER loc-fin-liab FOR ub.fin-ob-before .
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error .
if error-status :error then return '' .
define variable rr as character no-undo .
find first ub.currency no-lock where  ub.currency.curr-code  = loc-fin-liab.curr-code no-error.
if available ub.currency then  rr = ub.currency.curr-abbr .
else rr = ""   .

RETURN rr.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

