&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-alt-cds


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE alt-code NO-UNDO LIKE ub.bar-code
       field price-sale like ub.price-list.price-sale
       field d-pcnt like ub.price-list.d-pcnt
       field dtl-name as char
       field rid as recid
       field doc-num like ub.price-doc.doc-num

       .

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-alt-cds
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список неосновных кодов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

Author: Андрей Исаков
Created: 13.04.2001

Input Parameters:

mode:
code-current    - существующие неосновные коды с ценами по основному коду
scl-gds-current - существующие неосновные коды с ценами по признаками по товару
par-gds-current - существующие неосновные коды с ценами по партиям по товару
code-all        - все неосновные коды по основному коду
scl-gds-all     - все неосновные коды по признакам по товару
par-gds-all     - все неосновные коды по партиям по товару
all-no-part     - все основные и неосновные коды не по партии

g-code          - код товара
base-bc         - основной код

Output Parameters:

rec-list - список выбранных bar-code (по recid)

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input     parameter parparentproc  as widget-handle no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter mode       as character             no-undo.
define input parameter g-code     like ub.goods.gds-code  no-undo.
define input parameter base-bc    like ub.bar-code.b-code no-undo.
define output parameter rec-list  as character             no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список неосновных кодов".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/getcntxt.i def }
{ cmp/showinf.i }

define buffer base-bar-code for ub.bar-code.
define variable mark as char  no-undo.
define variable rid  as recid no-undo.
define variable glog as logical no-undo .

FUNCTION stts-string RETURNS CHARACTER ( p-stts_ as integer):
define variable dops as character no-undo.
&scop hn-action-code string(p-stts_)
assign dops = {&hn-action-name} no-error.

RETURN dops.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME d-alt-cds
&Scoped-define BROWSE-NAME br-cds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES alt-code

/* Definitions for BROWSE br-cds                                        */
&Scoped-define FIELDS-IN-QUERY-br-cds get-mark (alt-code.rid) @ mark alt-code.b-code alt-code.cli-base-rate alt-code.d-pcnt alt-code.price-sale alt-code.unit-cli alt-code.dtl-name alt-code.doc-num stts-string(alt-code.stts_) get-cr-db-num(alt-code.b-code, alt-code.cr-db-num)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-cds
&Scoped-define SELF-NAME br-cds
&Scoped-define QUERY-STRING-br-cds FOR EACH alt-code NO-LOCK
&Scoped-define OPEN-QUERY-br-cds OPEN QUERY {&SELdtl-name} FOR EACH alt-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-cds alt-code
&Scoped-define FIRST-TABLE-IN-QUERY-br-cds alt-code


/* Definitions for DIALOG-BOX d-alt-cds                                 */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-alt-cds ~
    ~{&OPEN-QUERY-br-cds}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sel b-mark b-add b-prod b-help ~
br-cds

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cr-db-num d-alt-cds
FUNCTION get-cr-db-num RETURNS INTEGER
  ( input p-b-code AS INTEGER, INPUT p-cr-db-num AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark d-alt-cds
FUNCTION get-mark RETURNS CHARACTER
  (local-rid as recid)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 15 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 7.5 BY 1.

DEFINE BUTTON b-prod
     LABEL "Д&оп. коды"
     SIZE 15 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 15 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-cds FOR
      alt-code SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-cds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-cds d-alt-cds _FREEFORM
  QUERY br-cds DISPLAY
      get-mark (alt-code.rid) @ mark format "x(1)"  column-label "*"
      alt-code.b-code                               column-label "Код"
      alt-code.cli-base-rate                        column-label "Коэф"
      alt-code.d-pcnt                               column-label "Скидка"
      alt-code.price-sale                           column-label "Цена"
      alt-code.unit-cli                             column-label "Изм"
      alt-code.dtl-name              format "x(34)" column-label "Привязка"
      alt-code.doc-num                              column-label "Переоценка"
      stts-string(alt-code.stts_) COLUMN-LABEL "Статус" FORMAT "X(10)"
      get-cr-db-num(alt-code.b-code, alt-code.cr-db-num) FORMAT ">>>>9" column-label "Создан (БД)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.88 BY 14.13.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-alt-cds
     b-quit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 16
     b-mark AT ROW 1 COL 31
     b-add AT ROW 1 COL 38.5
     b-prod AT ROW 1 COL 53.5
     b-help AT ROW 1 COL 95
     br-cds AT ROW 2.37 COL 1.1
     SPACE(0.50) SKIP(0.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список неосновных кодов:    "
         DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: alt-code T "?" NO-UNDO ub bar-code
      ADDITIONAL-FIELDS:
          field price-sale like price-list.price-sale
          field d-pcnt like price-list.d-pcnt
          field dtl-name as char
          field rid as recid
          field doc-num like price-doc.doc-num


      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-alt-cds
   FRAME-NAME                                                           */
/* BROWSE-TAB br-cds b-help d-alt-cds */
ASSIGN
       FRAME d-alt-cds:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-cds
/* Query rebuild information for BROWSE br-cds
     _START_FREEFORM
OPEN QUERY {&SELdtl-name} FOR EACH alt-code NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-cds */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-alt-cds
/* Query rebuild information for DIALOG-BOX d-alt-cds
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-alt-cds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-alt-cds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-alt-cds d-alt-cds
ON WINDOW-CLOSE OF FRAME d-alt-cds /* Список неосновных кодов:     */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-alt-cds
ON CHOOSE OF b-add IN FRAME d-alt-cds /* Добавить */
DO:
define variable v-prt-rec as recid no-undo .
case mode:
  when "code-all"
  then do:
    run ref/bc-form.w
      (input  parparentproc
      ,input  {&add-def}
      ,input  base-bc
      ,input-output rid
      ).
  end.
  when "scl-gds-all"
  then do:
    define variable v-sel-node-code as integer   no-undo .
    run str/prt-ref.w
      (input  parparentproc
      ,input  ub.goods.gds-code   /* p-gds-code      */
      ,input  {&lookup}        /* p-mode          */
      ,input  p-obj-type       /* p-obj-type      */
      ,input  p-obj-code       /* p-obj-code      */
      ,input  ""               /* p-doc-code      */
      ,input  ""               /* p-search-code   */
      ,output v-sel-node-code  /* p-sel-node-code */
      ) .
  end.
  when "par-gds-all"
  then do:
    define variable v-chk-act-host-code as integer   no-undo .
    { gbl/hostcode.i
      p-obj-type
      p-obj-code
      v-chk-act-host-code
    }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_archive_cost':U
      {&cntxt-object}
      v-chk-act-host-code
      p-obj-type
      p-obj-code
      0
      0
      0
      true
      glog
    }


    if NOT glog then
      return no-apply .
    run str/parts-l.w
      (INPUT parparentproc
      ,input p-obj-type                /* v-obj-type   */
      ,input p-obj-code                /* v-obj-code   */
      ,input goods.gds-code            /* p-gds-code   */
      ,input ""                        /* p-doc-code   */
      ,input {&lookup}                 /* p-edit-mode  */
      ,input {&parts-l_parts-rest}     /* p-r-parts    */
      ,input {&parts-l_object-current} /* p-one-all    */
      ,input {&parts-l_call-reference} /* p-call-point */
      ,output v-prt-rec                  /* part-recid   */
      ) .
  end.
  otherwise do:
    message
      "Для данного режима добавление не работает."
      view-as alert-box.
    return no-apply.
  end.
end case.
run UI-on.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-alt-cds
ON CHOOSE OF b-mark IN FRAME d-alt-cds /* * */
DO:
if not available alt-code then  return no-apply.
&scop seq {&sequence}
define variable v-num-entry{&seq} as integer no-undo .
assign
  v-num-entry{&seq} = lookup(string( alt-code.rid ), rec-list ).
if v-num-entry{&seq} > 0 then do:
  assign
    entry(v-num-entry{&seq}, rec-list) = "":U
    rec-list = replace( rec-list, {&comma-char} + {&comma-char}, {&comma-char}) .
  REC-LIST = TRIM(REC-LIST, {&COMMA-CHAR}).
end.
else do:
  assign
  rec-list = rec-list + ( if rec-list = "":U then "":U else {&comma-char} ) + string( alt-code.rid) .
end.
br-cds :refresh ().
if last-event :function <> "mouse-select-dblclick" then
  br-cds :select-next-row ().
apply "entry" to br-cds in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prod d-alt-cds
ON CHOOSE OF b-prod IN FRAME d-alt-cds /* Доп. коды */
DO:
def var rid-list as char no-undo.
def var drc-list as char no-undo init ''.
def var rid-nums as int  no-undo.

if not available alt-code then
  return no-apply.

/*почистим, если есть доп коды*/
do rid-nums = 1 to num-entries(rec-list, {&comma-char} ) :
    if not entry( rid-nums, rec-list, {&comma-char} ) begins "dk" then
    drc-list = drc-list + ( if drc-list = "":U then "":U else {&comma-char} ) + entry( rid-nums, rec-list, {&comma-char} ) .
end.
rec-list = drc-list .

run ref/prod-cds.w (parparentproc, p-obj-type, p-obj-code,
                "code-all", goods.gds-code, alt-code.b-code, output rid-list).

/*для передачи всех выбранных кодов при вызове из ref/dis-gdsi.w*/
if mode = "all-no-part-dk" then do:
    do rid-nums = 1 to num-entries(rid-list, {&comma-char} ) :
        rec-list = rec-list + ( if rec-list = "":U then "":U else {&comma-char} ) + "dk" + entry( rid-nums, rid-list, {&comma-char} ) .
    end.
end.

apply "entry" to br-cds in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-alt-cds
ON CHOOSE OF b-quit IN FRAME d-alt-cds /* Выход */
DO:
  rec-list = ''.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-alt-cds
ON CHOOSE OF b-sel IN FRAME d-alt-cds /* Выбор */
DO:
if rec-list = "" and
   available alt-code then
  rec-list = string (alt-code.rid).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-cds
&Scoped-define SELF-NAME br-cds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cds d-alt-cds
ON MOUSE-SELECT-DBLCLICK OF br-cds IN FRAME d-alt-cds
DO:
apply "choose" to b-mark in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cds d-alt-cds
ON RETURN OF br-cds IN FRAME d-alt-cds
DO:
apply "choose" to b-mark in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-alt-cds


{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-sel }
{ gbl/hot-key.i b-mark }

/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  find base-bar-code no-lock where
       base-bar-code.b-code = base-bc.
  find goods no-lock where
       goods.gds-code = g-code.

  RUN UI-on.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cre-alt d-alt-cds
PROCEDURE cre-alt :
/*------------------------------------------------------------------------------
  Purpose: заполнение одной строки таблицы
------------------------------------------------------------------------------*/
def var pr-rec   as   recid                  no-undo.
def var pr-c-b-r like ub.bar-code.cli-base-rate no-undo.

find ub.gds-prt no-lock where
     ub.gds-prt.node-code = ub.bar-code.node-code.
/* промежуточные отфильтровываем */
if not ub.gds-prt.root and
   not ub.gds-prt.is-term then
  return.
/* ищем предыдущую цену кода по текущему объекту */
/* base-bar-code.b-code */
{ gbl/bcodepls.i
  p-obj-type
  p-obj-code
  ub.bar-code.b-code
  0
  0
  pr-rec
  pr-c-b-r }

create alt-code.
buffer-copy ub.bar-code to alt-code
  assign
    alt-code.rid  = recid (bar-code)
    .
if ub.gds-prt.upper-code = ub.goods.prt-root then
  if ub.bar-code.in-code = "" then
    alt-code.dtl-name = "".
  else
    if ub.bar-code.part-code = "" then
      alt-code.dtl-name = ub.bar-code.in-code.
    else
      alt-code.dtl-name = ub.bar-code.in-code + " (" + ub.bar-code.part-code + ")".
else
  alt-code.dtl-name = ub.gds-prt.f-name.

find  ub.price-list no-lock where
      recid (ub.price-list) = pr-rec no-error.
if available ub.price-list and
   ub.price-list.b-code = ub.bar-code.b-code then
  /* нашли цену именно на этот неосновной код */
  assign
    alt-code.price-sale = ub.price-list.price-sale
    alt-code.d-pcnt     = ub.price-list.d-pcnt
    alt-code.doc-num    = ub.price-list.doc-num
    .
else
  if lookup (mode, "code-current,scl-gds-current,par-gds-current") > 0 then
    /* в списке не должно быть кодов, на которые не найдено старой переоценки */
    delete alt-code.
  else
    if available ub.price-list then
      /* цену вычисляем из главной или специальной */
      assign
        alt-code.price-sale = ub.price-list.price-sale * ub.bar-code.cli-base-rate
        alt-code.d-pcnt     = 0
        /* скобочками показываем, что цена унаследована */
        alt-code.doc-num    = "-"
        .
    else
      /* цены нет никакой */
      assign
        alt-code.price-sale = ?
        alt-code.d-pcnt     = ?
        alt-code.doc-num    = ?
        .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-alt-cds  _DEFAULT-DISABLE
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
  HIDE FRAME d-alt-cds.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on d-alt-cds
PROCEDURE UI-on :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ENABLE b-quit b-sel b-mark b-help b-prod br-cds WITH FRAME d-alt-cds.
for each alt-code:
  delete alt-code.
end.
case mode:
  when "all-no-part" or when "all-no-part-dk" then do:
    frame {&frame-name} :title = "Все имеющиеся основные и неосновные бар-коды:   " +
                                 "Основной код: " + string (base-bc, ">>>>>>>>9")
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code:
      if ub.bar-code.in-code   = base-bar-code.in-code and
      ub.bar-code.part-code = base-bar-code.part-code then do:
        run cre-alt.
      end.
    end.
  end.
  when "code-current" then do:
    frame {&frame-name} :title = "Имеющиеся неосновные цены:   " +
                                 "Основной код: " + string (base-bc, ">>>>>>>>9")
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.node-code = base-bar-code.node-code and
             ub.bar-code.in-code   = base-bar-code.in-code and
             ub.bar-code.part-code = base-bar-code.part-code and
             ub.bar-code.unit-cli <> ub.goods.unit-base:
      run cre-alt.
    end.
  end.
  when "scl-gds-current" then do:
    frame {&frame-name} :title = "Имеющиеся неосновные цены по признакам:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.in-code   = "" and
             ub.bar-code.unit-cli <> ub.goods.unit-base:
      run cre-alt.
    end.
  end.
  when "par-gds-current" then do:
    frame {&frame-name} :title = "Имеющиеся неосновные цены по партиям:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.in-code  <> "" and
             ub.bar-code.unit-cli <> ub.goods.unit-base:
      run cre-alt.
    end.
  end.
  when "code-all" then do:
    frame {&frame-name} :title = "Все неосновные коды:   " +
                                 "Основной код: " + string (base-bc, ">>>>>>>>9")
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.node-code = base-bar-code.node-code and
             ub.bar-code.in-code   = base-bar-code.in-code and
             ub.bar-code.part-code = base-bar-code.part-code and
             ub.bar-code.unit-cli <> ub.goods.unit-base:
      run cre-alt.
    end.
    ENABLE b-add WITH FRAME d-alt-cds.
  end.
  when "scl-gds-all" then do:
    frame {&frame-name} :title = "Все неосновные коды по признакам:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.in-code   = "" and
             ub.bar-code.unit-cli <> ub.goods.unit-base:
      run cre-alt.
    end.
    ENABLE b-add WITH FRAME d-alt-cds.
  end.
  when "par-gds-all" then do:
    frame {&frame-name} :title = "Все неосновные коды по партиям:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = base-bar-code.gds-code and
             ub.bar-code.in-code  <> "" and
             ub.bar-code.unit-cli <> ub.goods.unit-base:
      run cre-alt.
    end.
    ENABLE b-add WITH FRAME d-alt-cds.
  end.
end case.
frame {&frame-name} :title = frame {&frame-name} :title +
                             "      Текущий объект: " + string (p-obj-type, "x(3)") +
                             " " + string (p-obj-code, ">>>>9").
open query br-cds
  for each alt-code no-lock.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cr-db-num d-alt-cds
FUNCTION get-cr-db-num RETURNS INTEGER
  ( input p-b-code AS INTEGER, INPUT p-cr-db-num AS INTEGER) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  DEFINE BUFFER buf_code-range FOR ub.code-range.
  IF p-cr-db-num <> ? THEN
  RETURN p-cr-db-num.   /* Function return value. */
  FIND FIRST buf_code-range NO-LOCK WHERE
            buf_code-range.first-code <= p-b-code
       AND  buf_code-range.last-code >= p-b-code NO-ERROR.
  IF AVAILABLE buf_code-range THEN RETURN buf_code-range.db-num.
  RETURN ?.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-mark d-alt-cds
FUNCTION get-mark RETURNS CHARACTER
  (local-rid as recid) :
if lookup (string (local-rid), rec-list) > 0 then
  return "*".
else
  return "".
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME