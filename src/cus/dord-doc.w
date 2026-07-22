&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER buf_ord-doc FOR ub.ord-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список заказов по отобранным товарам

Автор: Чернова Светлана Александровна
Дата создания: 03/23/05
Author: Svetlana Chernova
Creation date: 03/23/05


Список заказов по временной таблице
*/
/*

doc-list должен быть определен заранее как new shared и содержать данные

*/
/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter parParentProc AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns   as character   no-undo . /*кнопки для нажатия*/
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-mode  as character   no-undo .
define input parameter p-sts   as character   no-undo .
define input-output param p-rid-list    as  character no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список заказов по отобранным товарам".
{ cmp/vssrevis.i   }
{ cmp/trg-def.i    }
{ cmp/showinf.i    }
{ cmp/r-pril.i new }
{ gbl/waitfram.i   }
{ gbl/prn-lib.i    }
{ gbl/cur-time.i   }
{ gbl/color.i      }
{ cmp/doc-list.i doc-list def "shared" }
{ gbl/getcntxt.i def    }
{ gbl/getcntxt.i get    }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }


define new shared buffer buf_doc-list for doc-list .
/* Для торг-26 */
define new shared variable sort-gr          as logical  no-undo.
define new shared variable print-graft      as logical init true  no-undo.

define new shared buffer shar-buf_ord-doc for ub.ord-doc.
define new shared buffer buf-or_ord-doc for ub.ord-doc.
define new shared buffer buf-OO_ord-doc for ub.ord-doc.

define variable next-prev as logical no-undo.
define variable bf-handle as handle no-undo.
define variable br-handle as handle no-undo.


define variable mark-str  as character no-undo.
define variable v-doc-rec as recid no-undo.
define variable filter-point as character no-undo init "Список открытых заказов по отобранным товарам" .
define variable filter-point0 as character no-undo init "Список_открытых_заказов" .
define variable sort-column-name as character no-undo .
define variable v-type     as character no-undo .
define variable p-mark     as character no-undo .
define variable p-obj      as character no-undo .
define variable p-time-upd as character no-undo .
define variable p-time-cr  as character no-undo .
define variable p-status   as character no-undo .


&SCOPED-DEFINE status-code buf_ord-doc.status_

&scop cop-l1    mark-string(recid(buf_ord-doc),p-rid-list)
&scop dyn_cop-l1    substitute('dynamic-function(&1mark-string&1, recid(buf_ord-doc) , &1&2&1 ) ' , ~{&double-quote~} , p-rid-list)
&scop cop-l2    buf_ord-doc.doc-code
&scop cop-l3    buf_ord-doc.doc-type
&scop cop-l4    buf_ord-doc.status_
&scop cop-l5    buf_ord-doc.doc-date
&scop cop-l6    buf_ord-doc.obj-type + ' ' + string(buf_ord-doc.obj-code)
&scop cop-l7    buf_ord-doc.cli-type + ' ' + string(buf_ord-doc.cli-code)
&scop cop-l8    buf_ord-doc.ship-date
&scop cop-l9    string(buf_ord-doc.ship-time, 'hh:mm')
&scop cop-l10   buf_ord-doc.date-sale-1
&scop cop-l11   buf_ord-doc.date-sale-2

&scop col-l1   '*'
&scop col-l2   'Номер'
&scop col-l3   'Тип'
&scop col-l4   'Статус'
&scop col-l5   'Дата'
&scop col-l6   'Объект'
&scop col-l7   'Контрагент'
&scop col-l8   'Доставка'
&scop col-l9   'Время'
&scop col-l10  'Для продажи с'
&scop col-l11  ' - по'

define variable v-obj as character no-undo .
define variable v-cli as character no-undo .

define buffer pos_ord-doc for ub.ord-doc.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_ord-doc no-lock where ~
                                  recid(pos_ord-doc) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи ЗАКАЗОВ" skip~
                            string(if avail pos_ord-doc ~
                                    then  substitute("№ заказа: &1" ~
                                                    , pos_ord-doc.doc-code) ~
                                    else "":U) skip ~
                            "Запись была добавлена (или изменена или удалена) -" skip ~
                            "и теперь не попадает в текущую выборку" ~
                            view-as alert-box WARNING. ~
                          end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-AM

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_doc-list buf_ord-doc

/* Definitions for BROWSE BROWSE-AM                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-AM {&cop-l1} {&cop-l2} {&cop-l3} {&cop-l4} {&cop-l5} {&cop-l6} {&cop-l7} {&cop-l8} {&cop-l9} {&cop-l10} {&cop-l11}   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-AM buf_ord-doc.doc-code   
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-AM buf_ord-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-AM buf_ord-doc
&Scoped-define SELF-NAME BROWSE-AM
&Scoped-define QUERY-STRING-BROWSE-AM FOR EACH     buf_doc-list , ~
           EACH buf_ord-doc NO-LOCK WHERE buf_ord-doc.doc-code = buf_doc-list.doc-code
&Scoped-define OPEN-QUERY-BROWSE-AM OPEN QUERY {&SELF-NAME} FOR EACH     buf_doc-list , ~
           EACH buf_ord-doc NO-LOCK WHERE buf_ord-doc.doc-code = buf_doc-list.doc-code .
&Scoped-define TABLES-IN-QUERY-BROWSE-AM buf_doc-list buf_ord-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-AM buf_doc-list
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-AM buf_ord-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-AM}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-lookup B-del B-close ~
B-print B-Help RS-sts RS-type F-doc-code BROWSE-AM v-PS B-add B-chg ~
mark-num FILL-IN-1 FILL-IN-2 
&Scoped-Define DISPLAYED-OBJECTS RS-sts RS-type F-doc-code v-PS mark-num ~
FILL-IN-1 FILL-IN-2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU m-print 
       MENU-ITEM m_print-1      LABEL "Печать заказа" 
       MENU-ITEM m_print-2      LABEL "Печать списка" .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-close 
     LABEL "&Закрыть" 
     SIZE 10 BY 1.

DEFINE BUTTON B-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON B-print 
     LABEL "Пе&чать" 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1.

DEFINE VARIABLE v-PS LIKE ub.ord-doc.PS
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 97 BY 2.54 NO-UNDO.

DEFINE VARIABLE F-doc-code AS CHARACTER FORMAT "X(256)":U 
     LABEL "Поиск по № заказа" 
     VIEW-AS FILL-IN 
     SIZE 18 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:" 
      VIEW-AS TEXT 
     SIZE 7.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Тип:" 
      VIEW-AS TEXT 
     SIZE 4.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 3 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-sts AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 85 BY 1 NO-UNDO.

DEFINE VARIABLE RS-type AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 84.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE NEW SHARED QUERY BROWSE-AM FOR
      buf_doc-list,
      buf_ord-doc SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-AM
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-AM Dialog-Frame _FREEFORM
  QUERY BROWSE-AM NO-LOCK DISPLAY
      {&cop-l1} COLUMN-LABEL {&col-l1} FORMAT "X(1)":U
   {&cop-l2} COLUMN-LABEL {&col-l2} FORMAT "X(14)":U
   {&cop-l3} COLUMN-LABEL {&col-l3} FORMAT "X(3)":U
   {&cop-l4} COLUMN-LABEL {&col-l4} FORMAT "X(9)":U
   {&cop-l5} COLUMN-LABEL {&col-l5} FORMAT "99/99/99":U
   {&cop-l6} COLUMN-LABEL {&col-l6} FORMAT  "X(10)":U
   {&cop-l7} COLUMN-LABEL {&col-l7} FORMAT  "X(10)":U
   {&cop-l8} COLUMN-LABEL {&col-l8} FORMAT  "99/99/99":U
   {&cop-l9} COLUMN-LABEL {&col-l9} FORMAT  "X(5)":U
   {&cop-l10} COLUMN-LABEL {&col-l10} FORMAT  "99/99/99":U
   {&cop-l11} COLUMN-LABEL {&col-l11} FORMAT  "99/99/99":U
  ENABLE
      buf_ord-doc.doc-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 13.5 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 17.5
     B-lookup AT ROW 1 COL 27.5
     B-del AT ROW 1 COL 37.5
     B-close AT ROW 1 COL 47.5
     B-print AT ROW 1 COL 77.5
     B-Help AT ROW 1 COL 87.5
     RS-sts AT ROW 2.5 COL 11.5 NO-LABEL
     RS-type AT ROW 3.5 COL 11.5 NO-LABEL
     F-doc-code AT ROW 4.5 COL 20 COLON-ALIGNED
     BROWSE-AM AT ROW 5.75 COL 1.5
     v-PS AT ROW 19.25 COL 1.5 HELP
          "" NO-LABEL
     B-add AT ROW 20.75 COL 76
     B-chg AT ROW 20.75 COL 87.5
     mark-num AT ROW 1 COL 12 COLON-ALIGNED NO-LABEL
     FILL-IN-1 AT ROW 2.5 COL 3.5 NO-LABEL
     FILL-IN-2 AT ROW 3.5 COL 6.5 NO-LABEL
     SPACE(87.74) SKIP(17.29)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Список заказов".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_ord-doc B "NEW SHARED" ? ub ord-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-AM F-doc-code Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-print:HANDLE.

ASSIGN 
       BROWSE-AM:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR EDITOR v-PS IN FRAME Dialog-Frame
   LIKE = ub.ord-doc.PS EXP-SIZE                                        */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-AM
/* Query rebuild information for BROWSE BROWSE-AM
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH
    buf_doc-list ,
    EACH buf_ord-doc NO-LOCK WHERE buf_ord-doc.doc-code = buf_doc-list.doc-code .
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE NEW SHARED QUERY BROWSE-AM FOR
      buf_doc-list,
      buf_ord-doc SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE BROWSE-AM */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "NO-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список заказов */
OR ENDKEY OF FRAME Dialog-Frame DO:
    run gbl/markqwa.p (
         input b-mark:sensitive
       , input p-rid-list) no-error.
    if error-status:error then return no-apply.

    APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
 define variable loc#log as logical no-undo.
 define variable loc-doc-rec as recid no-undo .

/* Проверка прав */

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pmnt-ord-doc_add-def':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }

  if not loc#log then return no-apply.



  if loc-doc-rec <> ? THEN DO:
      run openbr in this-procedure .
      reposition {&BROWSE-NAME} to recid loc-doc-rec no-error.
      {&cant-positioning}
  END.

  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
  apply "value-changed" to {&BROWSE-NAME} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available {&first-TABLE-IN-QUERY-{&BROWSE-NAME}} then return no-apply.
assign
  loc-doc-rec = recid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}})
  .
 /* Проверка прав */
   { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pmnt-ord-doc_add-def':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
    }
    if not loc#log then return no-apply.
    if loc-doc-rec <> ? THEN DO:
          run openbr in this-procedure .
          reposition {&BROWSE-NAME} to recid loc-doc-rec no-error.
          {&cant-positioning}
    END.

    apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
    apply "value-changed" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-close Dialog-Frame
ON CHOOSE OF B-close IN FRAME Dialog-Frame /* Закрыть */
DO:
  run proc-b-close in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
    run proc-b-del in this-procedure no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable loc#log as logical no-undo .

if not available {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} then return no-apply.

 /* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pmnt-ord-doc_lookup':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }
  if not loc#log
  then do:
    return . /* --->>>--- */
  end.

next-prev = no.
br-handle = {&BROWSE-NAME}:handle.
define variable  doc-rec as recid no-undo .

do while next-prev <> ?:
  if not available buf_ord-doc then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
  find first shar-buf_ord-doc no-lock where recid(shar-buf_ord-doc) = recid(buf_ord-doc) .
  find first buf-or_ord-doc   no-lock where recid(buf-or_ord-doc)   = recid(buf_ord-doc) .
  find first buf-OO_ord-doc   no-lock where recid(buf-OO_ord-doc)   = recid(buf_ord-doc) .
    bf-handle = buffer buf_ord-doc:handle .
    run cus/ord-zakz.p
      ( input  parParentProc ,
        input  {&lookup} ,
        input  buf_ord-doc.doc-type ,
        output doc-rec  ,
        input-output  br-handle ,
        input-output  bf-handle ,
        input-output  next-prev
        ) .
end.
if br-handle = ? then reposition {&BROWSE-NAME} to recid doc-rec no-error.

apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if AVAILABLE {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}  then do:
    { gbl/markstrn.i {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} p-rid-list }
    loc#log = {&BROWSE-NAME}:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = {&BROWSE-NAME}:select-next-row ().
        apply "VALUE-CHANGED" to {&BROWSE-NAME} in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  IF  p-rid-list = "" THEN DO:
      IF AVAILABLE buf_ord-doc THEN p-rid-list = string(RECID(buf_ord-doc)).
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-AM
&Scoped-define SELF-NAME BROWSE-AM
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-AM Dialog-Frame
ON ROW-DISPLAY OF BROWSE-AM IN FRAME Dialog-Frame
DO:
    /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-AM Dialog-Frame
ON VALUE-CHANGED OF BROWSE-AM IN FRAME Dialog-Frame
DO:
    v-PS = "" .
    IF AVAILABLE buf_ord-doc THEN DO:
        v-PS = buf_ord-doc.ps.

    END.

        DISPLAY
             v-PS WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME F-doc-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-doc-code Dialog-Frame
ON LEAVE OF F-doc-code IN FRAME Dialog-Frame /* Поиск по № заказа */
or return OF F-doc-code IN FRAME Dialog-Frame
DO:
 define variable v-recid as recid no-undo .
  ASSIGN f-doc-code .
  find first doc-list where doc-list.doc-code begins f-doc-code no-error .
  if available doc-list then do:
     v-recid = recid( doc-list ) .
      reposition {&BROWSE-NAME} to recid v-recid no-error.
      apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
      apply "value-changed" to {&BROWSE-NAME} in frame {&frame-name}.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_print-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_print-1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_print-1 /* Печать заказа */
DO:
 IF AVAILABLE {&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}} THEN DO:
     run cus/torg-26.p ( parParentProc , recid(buf_ord-doc) ).
 END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_print-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_print-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_print-2 /* Печать списка */
DO:
  run proc-b-print in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-sts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-sts Dialog-Frame
ON VALUE-CHANGED OF RS-sts IN FRAME Dialog-Frame
DO:
  assign RS-sts .
  run openbr in this-procedure no-error.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-type Dialog-Frame
ON VALUE-CHANGED OF RS-type IN FRAME Dialog-Frame
DO:

  assign
    RS-type
  .
  run openbr in this-procedure no-error.
  if error-status:error  then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = buf_ord-doc
  &label-clmn_1     =   "{&col-l1}"
  &label-clmn_2     =   "{&col-l2}"
  &label-clmn_3     =   "{&col-l3}"
  &label-clmn_4     =   "{&col-l4}"
  &label-clmn_5     =   "{&col-l5}"
  &label-clmn_6     =   "{&col-l6}"
  &label-clmn_7     =   "{&col-l7}"
  &label-clmn_8     =   "{&col-l8}"
  &label-clmn_9     =   "{&col-l9}"
  &label-clmn_10     =   "{&col-l10}"
  &label-clmn_11     =   "{&col-l11}"
  &sort-clmn_1    =   "{&cop-l1}"
  &dyn_sort-clmn_1    =   "{&dyn_cop-l1}"
  &sort-clmn_2    =   "{&cop-l2}"
  &sort-clmn_3    =   "{&cop-l3}"
  &sort-clmn_4    =   "{&cop-l4}"
  &sort-clmn_5    =   "{&cop-l5}"
  &sort-clmn_6    =   "{&cop-l6}"
  &sort-clmn_7    =   "{&cop-l7}"
  &sort-clmn_8    =   "{&cop-l8}"
  &sort-clmn_9    =   "{&cop-l9}"
  &sort-clmn_10    =   "{&cop-l10}"
  &sort-clmn_11    =   "{&cop-l11}"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}


{ gbl/brwrepos.i
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run my_enable in this-procedure .
  HIDE mark-num in frame {&frame-name} .
  if v-doc-rec <> ? then
  REPOSITION {&browse-name} to recid v-doc-rec No-ERROR.
ASSIGN b-print:POPUP-MENU IN FRAME {&frame-name} = MENU m-print:HANDLE.
ASSIGN b-print:MENU-MOUSE = 1.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui in this-procedure .

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
  DISPLAY RS-sts RS-type F-doc-code v-PS mark-num FILL-IN-1 FILL-IN-2 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-lookup B-del B-close B-print B-Help RS-sts 
         RS-type F-doc-code BROWSE-AM v-PS B-add B-chg mark-num FILL-IN-1 
         FILL-IN-2 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_enable Dialog-Frame 
PROCEDURE my_enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

buf_ord-doc.doc-code:read-only in browse {&browse-name} = true .
ASSIGN
rs-sts:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
          "Все" + {&comma-char} + {&all}            + {&comma-char} +
{&g___new}        + {&comma-char} + {&g___new}        + {&comma-char} +
{&ord-req}        + {&comma-char} + {&ord-req}        + {&comma-char} +
{&ord-alloc}      + {&comma-char} + {&ord-alloc}      + {&comma-char} +
{&ord-accept}     + {&comma-char} + {&ord-accept}     + {&comma-char} +
{&ord-rejection}  + {&comma-char} + {&ord-rejection}  + {&comma-char} +
{&ord-rcv}        + {&comma-char} + {&ord-rcv}        + {&comma-char} +
{&ord-close}      + {&comma-char} + {&ord-close}
.

rs-type:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
              "Все" + {&comma-char} + {&all} + {&comma-char} +
            {&f-p-full} + {&comma-char} +   {&f-p} + {&comma-char} +
            {&o-f-full} + {&comma-char} +   {&o-f} + {&comma-char} +
            {&o-p-full} + {&comma-char} +   {&o-p} + {&comma-char} +
            {&o-r-full} + {&comma-char} +   {&o-r} + {&comma-char} +
            {&o-o-full} + {&comma-char} +   {&o-o}
.

rs-sts = {&all} .
rs-type = {&all} .
DISPLAY mark-num
FILL-IN-1
FILL-IN-2
RS-sts
RS-type
WITH FRAME Dialog-Frame.

hide B-chg B-add in frame {&frame-name} .

ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-lookup
/* B-chg when LOOKUP("b-add":U, bttns) > 0 */
/* B-add when LOOKUP("b-add":U, bttns) > 0 */
B-del
B-print
B-Help
b-close
{&browse-name}
mark-num
RS-sts
RS-type
f-doc-code
with FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.

run openbr in this-procedure no-error.
if error-status:error  then return error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openBr Dialog-Frame 
PROCEDURE openBr :
define variable  p-open-query       as logical   no-undo init true .
define variable  l-query-was-opened as logical no-undo .
define variable  doc-rec            as recid     no-undo .
define variable  p-find-next        as logical   no-undo .
define variable  p-find-condition   as character no-undo .

ASSIGN  FRAME {&FRAME-NAME}
  rs-sts
  rs-type
    .
ASSIGN
  p-sts = (IF rs-sts = {&all} THEN ? ELSE rs-sts)
  v-type = (IF rs-type = {&all} THEN ? ELSE rs-type)
  .
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
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

define variable title0 as character no-undo init "Список открытых заказов по отобранным товарам ".


&scop flt-open-open-query OPEN QUERY BROWSE-AM  FOR EACH buf_doc-list

&scop flt-open-dyn_open-query  FOR EACH buf_doc-list

&scop flt-open-query-handle query BROWSE-AM:handle

&scop flt-open-find-buffer-name buf_doc-list


&scop flt-open-open-query-tail      , EACH buf_ord-doc NO-LOCK  where buf_ord-doc.doc-code = buf_doc-list.doc-code


&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          buf_doc-list

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer buf_doc-list for doc-list.

&scop flt-open-debug-file

&scop flt-open-waitfram             true

if v-type = ? then do:
    if p-sts = ? then do:
&scop flt-open-open-query-tail      , EACH buf_ord-doc NO-LOCK  where buf_ord-doc.doc-code = buf_doc-list.doc-code
        frame {&frame-name}:TITLE = title0  .
                { gbl/fltopend.i
                  &where-cond = " "
                  &dyn_where-cond = " 'yes' "
                  &use-ind    = " "
                  &by         = " " }
    end.
    else do:
&scop flt-open-open-query-tail      , EACH buf_ord-doc NO-LOCK  where buf_ord-doc.doc-code = buf_doc-list.doc-code and buf_ord-doc.status_ = p-sts

&scop flt-open-dyn_open-query-tail  substitute(', EACH buf_ord-doc NO-LOCK  where buf_ord-doc.doc-code = buf_doc-list.doc-code AND  buf_ord-doc.status_ = &1&2&1 ' , ~{&double-quote~} , p-sts)

      frame {&frame-name}:TITLE = title0 + "Статус: " + p-sts .
              { gbl/fltopend.i
                &where-cond = " "
                &dyn_where-cond = " 'yes' "
                &use-ind    = " "
                &by         = " " }
    end.
end.

else do:
    if p-sts = ? then do:

&scop flt-open-open-query-tail      , EACH buf_ord-doc NO-LOCK  where buf_ord-doc.doc-code = buf_doc-list.doc-code

&scop flt-open-dyn_open-query-tail  substitute(', EACH buf_ord-doc NO-LOCK  where buf_ord-doc.doc-code = buf_doc-list.doc-code ' )

    frame {&frame-name}:TITLE = title0 + " ТИП: " + v-type .
            { gbl/fltopend.i
              &where-cond = " buf_doc-list.doc-type = v-type "
              &dyn_where-cond = " substitute(' buf_doc-list.doc-type  = &1&2&1 ' , ~{&double-quote~} , v-type) "
              &use-ind    = " "
              &by         = " " }
    end.
    else do:

&scop flt-open-open-query-tail      , EACH buf_ord-doc NO-LOCK  where buf_ord-doc.doc-code = buf_doc-list.doc-code and buf_ord-doc.status_ = p-sts

&scop flt-open-dyn_open-query-tail  substitute(', EACH buf_ord-doc NO-LOCK  where buf_ord-doc.doc-code = buf_doc-list.doc-code AND  buf_ord-doc.status_ = &1&2&1 ' , ~{&double-quote~} , p-sts)

    frame {&frame-name}:TITLE = title0  + " ТИП: " + v-type + "Статус: " + p-sts .
            { gbl/fltopend.i
              &where-cond = "  buf_doc-list.doc-type = v-type  "
              &dyn_where-cond = " substitute(' buf_doc-list.doc-type  = &1&2&1 ' , ~{&double-quote~} , v-type  ) "
              &use-ind    = " "
              &by         = " " }
    end.

end.

APPLY "VALUE-CHANGED" TO {&BROWSE-NAME} in frame {&frame-name}.
APPLY "ENTRY" TO {&BROWSE-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-close Dialog-Frame 
PROCEDURE proc-b-close :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable loc-doc-rec as recid no-undo .
define variable v-log as logical   no-undo .
if not available buf_ord-doc then return.

  loc-doc-rec = recid(buf_ord-doc).

  run cus/ord-clos.p (
      input parParentProc  ,
      input loc-doc-rec    ,
      input v-cntxt-obj-type ,
      input v-cntxt-obj-code ,
      input g#db-num        ,
      input false           ,
      input  "no" /*p-param-list пока тока один параметр, говорит что edi или не edi*/           )
      no-error .
  if error-status:error then do:
     message
       error-status :get-message(1) skip
       return-value skip
       ""
       view-as alert-box error
     .
     undo, return error.
  end.

  run openbr in this-procedure .
  reposition {&browse-name} to recid loc-doc-rec no-error.
  if available buf_ord-doc then do:
    v-log = {&browse-name}:select-focused-row( ) in frame {&frame-name}.
  end.
  apply "ENTRY" to {&browse-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame 
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
on stop undo, return error
:
define variable loc#log as logical no-undo.
define variable v-sts like ub.ord-doc.status_ no-undo .
define variable loc-doc-rec as recid no-undo.
define variable g#log as logical   no-undo .


if not available buf_ord-doc then return error.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pmnt-ord-doc_deletion':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }

if not loc#log then return error.


    find current buf_ord-doc exclusive-lock .
    if error-status :error then return .

    if buf_ord-doc.status_ <> 'новый':U  then do:
      message "Заказ в статусе" buf_ord-doc.status_ "удалять нельзя! " view-as alert-box error .
      return .
    end.
    g#log = no.
    message "Удалить документ №" buf_ord-doc.doc-code  " из базы данных ?   Вы уверены ?"
                    view-as alert-box question buttons OK-Cancel update g#log.
    if g#log then do:
      delete buf_ord-doc no-error .
    end.

  if error-status:error then undo, return error.
  run openbr in this-procedure .
  reposition {&browse-name} to recid loc-doc-rec no-error.
  if available buf_ord-doc then do:
    loc#log = {&browse-name}:select-focused-row( ) in frame {&frame-name}.
  end.
  apply "ENTRY" to {&browse-name}.
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

define variable v-doc-rec   as recid     no-undo .
define variable accum-count as integer   no-undo .
define variable date_string as character no-undo .
define variable Line        as character no-undo .
define variable v-st        as character no-undo .

DEFINE FRAME buf_ord-doc-list
      buf_ord-doc.doc-code  COLUMN-LABEL {&col-l2} FORMAT "X(14)":U
      buf_ord-doc.doc-type  COLUMN-LABEL {&col-l3} FORMAT "X(3)":U
      buf_ord-doc.status_   COLUMN-LABEL {&col-l4} FORMAT "X(8)":U
      buf_ord-doc.doc-date  COLUMN-LABEL {&col-l5} FORMAT "99/99/99":U
      v-obj                 COLUMN-LABEL {&col-l6} FORMAT  "X(10)":U
      v-cli                 COLUMN-LABEL {&col-l7} FORMAT  "X(10)":U
      buf_ord-doc.ship-date COLUMN-LABEL {&col-l8} FORMAT  "99/99/99":U
      v-st                  COLUMN-LABEL {&col-l9} FORMAT  "X(5)":U
      {&cop-l10} COLUMN-LABEL {&col-l10} FORMAT  "99/99/99":U
      {&cop-l11} COLUMN-LABEL {&col-l11} FORMAT  "99/99/99":U


HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 195).
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
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME buf_ord-doc-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(buf_ord-doc).
DO WHILE available buf_ord-doc :
  GET prev {&browse-name}.
END.
GET next {&browse-name}.
DO WHILE available buf_ord-doc :
  Display STREAM PrnLibStream
      buf_ord-doc.doc-code
      buf_ord-doc.doc-type
      buf_ord-doc.status_
      buf_ord-doc.doc-date
      buf_ord-doc.obj-type + ' ' + string(buf_ord-doc.obj-code)  @ v-obj
      buf_ord-doc.cli-type + ' ' + string(buf_ord-doc.cli-code)  @ v-cli
      buf_ord-doc.ship-date
       string(buf_ord-doc.ship-time, "hh:mm") @ v-st
       {&cop-l10}
       {&cop-l11}

with FRAME buf_ord-doc-list .
  DOWN STREAM PrnLibStream 1
  with FRAME buf_ord-doc-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next {&browse-name}.
END.
UNDERLINE  STREAM PrnLibStream
      buf_ord-doc.doc-code
      buf_ord-doc.doc-type
      buf_ord-doc.status_
      buf_ord-doc.doc-date
      v-obj
      v-cli
      buf_ord-doc.ship-date
      v-st
      {&cop-l10}
      {&cop-l11}
with frame buf_ord-doc-list .
display stream prnlibstream
with frame buf_ord-doc-list.
hide  stream prnlibstream frame bottomframe .
hide  stream prnlibstream frame buf_ord-doc-list.
output  stream prnlibstream close.
reposition {&browse-name} to recid v-doc-rec no-error.
apply "ENTRY" to {&browse-name}.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure
    ( input parParentProc
     ,input 8
    ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br Dialog-Frame 
PROCEDURE proc-br :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/* { ref/brwsretr.i } */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

