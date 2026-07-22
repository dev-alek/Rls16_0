&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-bas-cds


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE bas-code NO-UNDO LIKE ub.bar-code
       field price-sale like ub.price-list.price-sale
       field f-name like ub.gds-prt.f-name
       field rid as recid
       field doc-num like ub.price-doc.doc-num
       field qnty as decimal
       .



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-bas-cds
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список основных кодов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

Input Parameters:

mode:
gds-current - существующие основные коды с ценами по товару
scl-gds-all - все основные коды по признакам по товару
par-gds-all - все основные коды по партиям по товару
par-gds-free -  основные коды по партиям по товару по партиям свободной зоны и незакрытых ПН
gds-all     - все основные коды по товару

g-code          - код товара

Output Parameters:

rec-list - список выбранных bar-code (по recid)

Author: Андрей Исаков
Created: 13.04.2001

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc   as widget-handle         no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter mode            as character             no-undo .
define input parameter g-code          like ub.goods.gds-code      no-undo .
define output parameter p-rec-list       as character             no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список основных кодов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define variable  mark as character  no-undo.
define variable  rid  as recid no-undo.
define variable glog  as logical no-undo .
define variable v-rec-list as character no-undo .

define buffer buf_parts for ub.parts  .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-bas-cds
&Scoped-define BROWSE-NAME br-cds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES bas-code

/* Definitions for BROWSE br-cds                                        */
&Scoped-define FIELDS-IN-QUERY-br-cds get-mark (bas-code.rid) @ mark bas-code.b-code bas-code.price-sale bas-code.unit-cli bas-code.f-name bas-code.in-code bas-code.part-code bas-code.doc-num bas-code.qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-cds
&Scoped-define SELF-NAME br-cds
&Scoped-define QUERY-STRING-br-cds FOR EACH bas-code NO-LOCK
&Scoped-define OPEN-QUERY-br-cds OPEN QUERY {&SELF-NAME} FOR EACH bas-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-cds bas-code
&Scoped-define FIRST-TABLE-IN-QUERY-br-cds bas-code


/* Definitions for DIALOG-BOX d-bas-cds                                 */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-bas-cds ~
    ~{&OPEN-QUERY-br-cds}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sel b-mark b-add b-help br-cds

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark d-bas-cds
FUNCTION get-mark RETURNS CHARACTER
  (local-rid as recid)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 4 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-cds FOR
      bas-code SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-cds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-cds d-bas-cds _FREEFORM
  QUERY br-cds DISPLAY
      get-mark (bas-code.rid) @ mark format "x(1)" column-label "*"
      bas-code.b-code                              column-label "Код"
      bas-code.price-sale   format ">>>>>>>>>>9.99"  column-label "Цена"
      bas-code.unit-cli                            column-label "Изм"
      bas-code.f-name
      bas-code.in-code         format "x(14)"     column-label "ПН"
      bas-code.part-code      format "x(14)"
      bas-code.doc-num        format "x(14)"      column-label "Переоценка"
      bas-code.qnty                                column-label "Кол-во"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 100.38 BY 14.13.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-bas-cds
     b-quit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     b-mark AT ROW 1 COL 21
     b-add AT ROW 1 COL 24
     b-help AT ROW 1 COL 95.5
     br-cds AT ROW 2.38 COL 1.13
     SPACE(0.23) SKIP(0.27)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список основных кодов:    "
         DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: bas-code T "?" NO-UNDO ub bar-code
      ADDITIONAL-FIELDS:
          field price-sale like price-list.price-sale
          field f-name like gds-prt.f-name
          field rid as recid
          field doc-num like price-doc.doc-num
          field qnty as decimal

      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-bas-cds
   FRAME-NAME                                                           */
/* BROWSE-TAB br-cds b-help d-bas-cds */
ASSIGN
       FRAME d-bas-cds:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-cds
/* Query rebuild information for BROWSE br-cds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH bas-code NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-cds */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-bas-cds
/* Query rebuild information for DIALOG-BOX d-bas-cds
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-bas-cds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-bas-cds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-bas-cds d-bas-cds
ON GO OF FRAME d-bas-cds /* Список основных кодов */
DO:
  p-rec-list = v-rec-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME d-bas-cds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-bas-cds d-bas-cds
ON WINDOW-CLOSE OF FRAME d-bas-cds /* Список основных кодов:     */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-bas-cds
ON CHOOSE OF b-add IN FRAME d-bas-cds /* Добавить */
DO:
define variable v-prt-rec as recid no-undo .
case mode:
  when "scl-gds-all" then do:
    define variable v-sel-node-code as integer   no-undo .
    run str/prt-ref.w
      (INPUT  parparentproc
      ,input  ub.goods.gds-code  /* p-gds-code      */
      ,input  {&lookup}       /* p-mode          */
      ,input  p-curr-obj-type      /* p-obj-type      */
      ,input  p-curr-obj-code      /* p-obj-code      */
      ,input  ""              /* p-doc-code      */
      ,input  ""              /* p-search-code   */
      ,output v-sel-node-code /* p-sel-node-code */
      ) .
  end.
  when "par-gds-free" then do:
  end.
  when "par-gds-all" then do:
    define variable v-chk-act-host-code as integer   no-undo .
    { gbl/hostcode.i
      p-curr-obj-type
      p-curr-obj-code
      v-chk-act-host-code
    }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_archive_cost':U
      {&cntxt-object}
      v-chk-act-host-code
      p-curr-obj-type
      p-curr-obj-code
      0
      0
      0
      true
      glog
    }

    if NOT glog then return no-apply .
    run str/parts-l.w
      (
       input parparentproc
      ,input p-curr-obj-type           /* v-obj-type   */
      ,input p-curr-obj-code           /* v-obj-code   */
      ,input goods.gds-code            /* p-gds-code   */
      ,input ""                        /* p-doc-code   */
      ,input {&lookup}                 /* p-edit-mode  */
      ,input {&parts-l_parts-rest}     /* p-r-parts    */
      ,input {&parts-l_object-current} /* p-one-all    */
      ,input {&parts-l_call-reference} /* p-call-point */
      ,output v-prt-rec                 /* part-recid   */
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
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-bas-cds
ON CHOOSE OF b-mark IN FRAME d-bas-cds /* * */
DO:
if not available bas-code then  return no-apply.
&scop seq {&sequence}
define variable v-num-entry{&seq} as integer no-undo .
assign
  v-num-entry{&seq} = lookup(string( bas-code.rid ), v-rec-list ).
if v-num-entry{&seq} > 0 then do:
  assign
    entry(v-num-entry{&seq}, v-rec-list) = "":U
    v-rec-list = replace( v-rec-list, {&comma-char} + {&comma-char}, {&comma-char}) .
end.
else do:
  assign
  v-rec-list = v-rec-list + ( if v-rec-list = "":U then "":U else {&comma-char} ) + string( bas-code.rid) .
end.
br-cds :refresh ().
if last-event :function <> "mouse-select-dblclick" then
  br-cds :select-next-row ().
apply "entry" to br-cds in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-bas-cds
ON CHOOSE OF b-sel IN FRAME d-bas-cds /* Выбор */
DO:
if v-rec-list = "" and
   available bas-code then
  v-rec-list = string (bas-code.rid).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-cds
&Scoped-define SELF-NAME br-cds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cds d-bas-cds
ON MOUSE-SELECT-DBLCLICK OF br-cds IN FRAME d-bas-cds
DO:
apply "choose" to b-mark in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cds d-bas-cds
ON RETURN OF br-cds IN FRAME d-bas-cds
DO:
apply "choose" to b-mark in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-bas-cds


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

  find goods no-lock where
       goods.gds-code = g-code.
  v-rec-list = p-rec-list.
  RUN UI-on.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cre-bas d-bas-cds
PROCEDURE cre-bas :
/*------------------------------------------------------------------------------
  Purpose: заполнение одной строки таблицы
------------------------------------------------------------------------------*/
def var pr-rec   as   recid                  no-undo.
def var pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
define buffer buf2_parts for ub.parts  .
define buffer buf2_goods for ub.goods  .

find ub.gds-prt no-lock where
     ub.gds-prt.node-code = ub.bar-code.node-code.
/* главную цену отфильтровываем */
if ub.bar-code.in-code = "" and
   ub.gds-prt.upper-code = ub.goods.prt-root then
  return.
/* промежуточные отфильтровываем */
if not ub.gds-prt.root and
   not ub.gds-prt.is-term then
  return.
/* ищем предыдущую цену кода по текущему объекту */
{ gbl/bcodepls.i
  p-curr-obj-type
  p-curr-obj-code
  ub.bar-code.b-code
  0
  0
  pr-rec
  pr-c-b-r }

create bas-code.
buffer-copy ub.bar-code to bas-code
  assign
    bas-code.rid  = recid (ub.bar-code)
    .
if ub.gds-prt.upper-code = ub.goods.prt-root then
  bas-code.f-name = "".
else
  bas-code.f-name = ub.gds-prt.f-name.

find  ub.price-list no-lock where
      recid (ub.price-list) = pr-rec no-error.
if available ub.price-list and
   ub.price-list.b-code = ub.bar-code.b-code then
  /* нашли цену именно на этот основной код (спеццену) */
  assign
    bas-code.price-sale = ub.price-list.price-sale
    bas-code.doc-num    = ub.price-list.doc-num
    .
else
  if lookup (mode, "gds-current") > 0 then
    /* в списке не должно быть кодов, на которые не найдено старой переоценки */
    delete bas-code.
  else
    /* цену в этом справочнике не вычисляем, чтобы было видно, что ее нет
      коэф всегда берем из бар-кода по той же причине
    */
    assign
      bas-code.price-sale = ?
      bas-code.doc-num    = ?
      .
 bas-code.qnty    = 0.
if mode = "par-gds-free" then do:
find first buf2_goods no-lock  where
           buf2_goods.gds-code = g-code no-error .
find first buf2_parts no-lock where
      buf2_parts.out-code  = {&free-code} and
      buf2_parts.obj-type = p-curr-obj-type and
      buf2_parts.obj-code = p-curr-obj-code and
      buf2_parts.rsrv-free = true    and
      buf2_parts.status_   = false   and
      buf2_parts.in-code   = bar-code.in-code  and
      buf2_parts.part-code   = bar-code.part-code  and
      buf2_parts.artic     = buf2_goods.artic  and
      buf2_parts.prod-type = buf2_goods.prod-type  and
      buf2_parts.prod-code = buf2_goods.prod-code no-error .

    if available buf2_parts then do:
       bas-code.qnty    = buf2_parts.fact-qnty .
    end.
    else do:
       bas-code.qnty    = ?.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-bas-cds  _DEFAULT-DISABLE
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
  HIDE FRAME d-bas-cds.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on d-bas-cds 
PROCEDURE UI-on :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ENABLE b-quit b-sel b-mark b-help br-cds WITH FRAME d-bas-cds.
for each bas-code:
  delete bas-code.
end.
case mode:
  when "gds-current" then do:
    frame {&frame-name} :title = "Имеющиеся основные цены:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = ub.goods.gds-code and
             ub.bar-code.unit-cli  = ub.goods.unit-base:
      run cre-bas.
    end.
  end.
  when "scl-gds-all" then do:
    frame {&frame-name} :title = "Все основные коды по признакам:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = ub.goods.gds-code and
             ub.bar-code.in-code   = "" and
             ub.bar-code.unit-cli  = ub.goods.unit-base:
      run cre-bas.
    end.
    ENABLE b-add WITH FRAME d-bas-cds.
  end.
  when "par-gds-all" then do:
    frame {&frame-name} :title = "Все основные коды по партиям:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = ub.goods.gds-code and
             ub.bar-code.in-code  <> "" and
             ub.bar-code.unit-cli  = ub.goods.unit-base:
      run cre-bas.
    end.
    ENABLE b-add WITH FRAME d-bas-cds.
  end.
  when "par-gds-free" then do:
    frame {&frame-name} :title = "Основные коды по партиям свободной зоны и незакрытых ПН:   " +
                                 "Товар: " + goods.artic + "  " + goods.gds-name
                                 .


    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = ub.goods.gds-code and
             ub.bar-code.in-code  <> "" and
             ub.bar-code.unit-cli  = ub.goods.unit-base,
       first buf_parts no-lock where
             buf_parts.out-code = {&free-code}  and
             buf_parts.status_  = false   and
             buf_parts.rsrv-free = true    and
             buf_parts.in-code  = ub.bar-code.in-code  and
             buf_parts.part-code  = ub.bar-code.part-code  and
             buf_parts.artic     = ub.goods.artic  and
             buf_parts.prod-type = ub.goods.prod-type  and
             buf_parts.prod-code = ub.goods.prod-code

             :
      run cre-bas.
    end.
    hide b-add in frame d-bas-cds.
  end.

  when "gds-all" then do:
    frame {&frame-name} :title = "Все основные коды по товару:   " +
                                 "Товар: " + ub.goods.artic + "  " + ub.goods.gds-name
                                 .
    for each ub.bar-code no-lock where
             ub.bar-code.gds-code  = ub.goods.gds-code and
             ub.bar-code.unit-cli  = ub.goods.unit-base:
      run cre-bas.
    end.
  end.
end case.
frame {&frame-name} :title = frame {&frame-name} :title +
                             "      Текущий объект: " + string (p-curr-obj-type, "x(3)") +
                             " " + string (p-curr-obj-code, ">>>>9").
open query br-cds
  for each bas-code no-lock.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-mark d-bas-cds 
FUNCTION get-mark RETURNS CHARACTER
  (local-rid as recid) :
if lookup (string (local-rid), v-rec-list) > 0 then
  return "*".
else
  return "".
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

