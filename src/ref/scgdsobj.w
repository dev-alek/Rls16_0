&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_gds-obj FOR ub.gds-obj.
DEFINE BUFFER X_gds-obj-attr FOR ub.gds-obj-attr.
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE BUFFER X_units FOR ub.units.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список весовых товаров магазина

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/26/01
Author: Bakhtadze Natalya
Creation date: 10/26/01

*/


/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список весовых товаров магазина".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ ref/gdsoattr.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ str/libbcrcn.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }

define buffer l-goods for ub.goods.
define buffer l-bar-code for ub.bar-code.
define buffer l-prod-bc for ub.prod-bc.
define buffer l-gds-obj-attr for ub.gds-obj-attr.


define variable filter-label0 as character no-undo init "Весовые_товары" .
define variable filter-label as character no-undo init "Весовые_товары" .
define variable filter-point as character no-undo init "scgdsobj".
define variable filter-point0 as character no-undo init "scgdsobj".
define variable sort-column-name as character no-undo .
define variable code-option as character no-undo.
define variable line-rec as recid no-undo .
define variable gds-rec     as recid             no-undo.
define variable v-doc-rec as recid no-undo .
/* для чтения параметра конфигурации */
define variable conf-par as char no-undo.
define variable par-type as char no-undo.
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_goods X_units X_gds-obj X_gds-obj-attr

/* Definitions for BROWSE BR-gds                                        */
&Scoped-define FIELDS-IN-QUERY-BR-gds X_goods.artic X_goods.gds-code X_goods.gds-name X_gds-obj-attr.attr-value X_goods.grp-name X_gds-obj.price-sale X_gds-obj.fact-qnty X_gds-obj.free-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-gds X_gds-obj-attr.attr-value
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-gds X_gds-obj-attr
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-gds X_gds-obj-attr
&Scoped-define SELF-NAME BR-gds
&Scoped-define QUERY-STRING-BR-gds FOR EACH X_goods NO-LOCK, ~
             FIRST X_units WHERE X_units.unit-name = X_goods.unit-base       AND LOOKUP({&weight}, ~
       X_units.type) > 0 NO-LOCK, ~
             FIRST X_gds-obj WHERE X_gds-obj.gds-code = X_goods.gds-code   AND X_gds-obj.obj-type = p-obj-type   AND X_gds-obj.obj-code = p-obj-code OUTER-JOIN NO-LOCK, ~
             FIRST X_gds-obj-attr WHERE X_gds-obj-attr.gds-code = X_gds-obj.gds-code   AND X_gds-obj-attr.obj-type = X_gds-obj.obj-type   AND X_gds-obj-attr.obj-code = X_gds-obj.obj-code       AND X_gds-obj-attr.attr-code = {&attr-scales-code-o} OUTER-JOIN NO-LOCK
&Scoped-define OPEN-QUERY-BR-gds OPEN QUERY {&SELF-NAME} FOR EACH X_goods NO-LOCK, ~
             FIRST X_units WHERE X_units.unit-name = X_goods.unit-base       AND LOOKUP({&weight}, ~
       X_units.type) > 0 NO-LOCK, ~
             FIRST X_gds-obj WHERE X_gds-obj.gds-code = X_goods.gds-code   AND X_gds-obj.obj-type = p-obj-type   AND X_gds-obj.obj-code = p-obj-code OUTER-JOIN NO-LOCK, ~
             FIRST X_gds-obj-attr WHERE X_gds-obj-attr.gds-code = X_gds-obj.gds-code   AND X_gds-obj-attr.obj-type = X_gds-obj.obj-type   AND X_gds-obj-attr.obj-code = X_gds-obj.obj-code       AND X_gds-obj-attr.attr-code = {&attr-scales-code-o} OUTER-JOIN NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-gds X_goods X_units X_gds-obj ~
X_gds-obj-attr
&Scoped-define FIRST-TABLE-IN-QUERY-BR-gds X_goods
&Scoped-define SECOND-TABLE-IN-QUERY-BR-gds X_units
&Scoped-define THIRD-TABLE-IN-QUERY-BR-gds X_gds-obj
&Scoped-define FOURTH-TABLE-IN-QUERY-BR-gds X_gds-obj-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-scales B-code B-chg B-sch B-Help ~
loc-name loc-code loc-art a-n-c RS-mode BR-gds
&Scoped-Define DISPLAYED-OBJECTS loc-name loc-code loc-art a-n-c RS-mode

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-code
       MENU-ITEM m_Prod-bc      LABEL "Весовые"
       MENU-ITEM m_all          LABEL "Все"           .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-chg
     LABEL "Смена вес. кода"
     SIZE 20 BY 1.

DEFINE BUTTON B-code
     LABEL "&Коды"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-scales
     LABEL "Вес&ы"
     SIZE 10 BY 1.

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE VARIABLE loc-art AS CHARACTER FORMAT "X(256)":U
     LABEL "Начало артикула"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE loc-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Бар-код (весь)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE loc-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Начало названия"
     VIEW-AS FILL-IN
     SIZE 20 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE a-n-c AS CHARACTER INITIAL "art"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&А", "art",
"&Н", "name",
"&К", "code",
"Вес.код", "ves"
     SIZE 25.25 BY 1 NO-UNDO.

DEFINE VARIABLE RS-mode AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Факт", "1",
"Объект", "2"
     SIZE 18.5 BY .75 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-gds FOR
      X_goods,
      X_units,
      X_gds-obj,
      X_gds-obj-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-gds Dialog-Frame _FREEFORM
  QUERY BR-gds NO-LOCK DISPLAY
      X_goods.artic FORMAT "X(16)":U
      X_goods.gds-code FORMAT "999999999":U
      X_goods.gds-name FORMAT "X(30)":U
      X_gds-obj-attr.attr-value COLUMN-LABEL "Текущий!вес.код" FORMAT "X(5)":U
      X_goods.grp-name FORMAT "X(40)":U
      X_gds-obj.price-sale FORMAT "->>>,>>>,>>9.99":U
      X_gds-obj.fact-qnty FORMAT "->>,>>>,>>9.<<<":U
      X_gds-obj.free-qnty FORMAT "->>,>>>,>>9.<<<":U
  ENABLE
      X_gds-obj-attr.attr-value
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 17.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-scales AT ROW 1 COL 11
     B-code AT ROW 1 COL 21
     B-chg AT ROW 1 COL 41
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     loc-name AT ROW 2.5 COL 51.5 COLON-ALIGNED
     loc-code AT ROW 2.5 COL 51.5 COLON-ALIGNED
     loc-art AT ROW 2.5 COL 51.5 COLON-ALIGNED
     a-n-c AT ROW 2.54 COL 9.75 NO-LABEL
     RS-mode AT ROW 2.58 COL 78.13 NO-LABEL
     BR-gds AT ROW 4.04 COL 1
     "Поиск:" VIEW-AS TEXT
          SIZE 7.5 BY 1 AT ROW 2.54 COL 1.63
     SPACE(89.87) SKIP(18.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Весовые товары магазина"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_gds-obj B "?" ? ub gds-obj
      TABLE: X_gds-obj-attr B "?" ? ub gds-obj-attr
      TABLE: X_goods B "?" ? ub goods
      TABLE: X_units B "?" ? ub units
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-gds RS-mode Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-code:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-code:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-gds
/* Query rebuild information for BROWSE BR-gds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_goods NO-LOCK,
      FIRST X_units WHERE X_units.unit-name = X_goods.unit-base
      AND LOOKUP({&weight}, X_units.type) > 0 NO-LOCK,
      FIRST X_gds-obj WHERE X_gds-obj.gds-code = X_goods.gds-code
  AND X_gds-obj.obj-type = p-obj-type
  AND X_gds-obj.obj-code = p-obj-code OUTER-JOIN NO-LOCK,
      FIRST X_gds-obj-attr WHERE X_gds-obj-attr.gds-code = X_gds-obj.gds-code
  AND X_gds-obj-attr.obj-type = X_gds-obj.obj-type
  AND X_gds-obj-attr.obj-code = X_gds-obj.obj-code
      AND X_gds-obj-attr.attr-code = {&attr-scales-code-o} OUTER-JOIN NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ", FIRST, FIRST OUTER, FIRST OUTER"
     _JoinCode[2]      = "units.unit-name = goods.unit-base"
     _Where[2]         = "LOOKUP({&weight}, units.type) > 0"
     _JoinCode[3]      = "gds-obj.gds-code = goods.gds-code
  AND gds-obj.obj-type = p-obj-type
  AND gds-obj.obj-code = p-obj-code"
     _JoinCode[4]      = "gds-obj-attr.gds-code = gds-obj.gds-code
  AND gds-obj-attr.obj-type = gds-obj.obj-type
  AND gds-obj-attr.obj-code = gds-obj.obj-code"
     _Where[4]         = "gds-obj-attr.attr-code = {&attr-scales-code-o}"
     _Query            is NOT OPENED
*/  /* BROWSE BR-gds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Весовые товары магазина */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Смена вес. кода */
DO:
  define variable r-bar-code like ub.bar-code.b-code no-undo.
  define variable ref-list as character no-undo.
  define variable glog as logical no-undo .
  define variable gds-rec as recid no-undo .
  define variable v-obj-db-num as integer no-undo .
  define buffer buf_scales-gds for ub.scales-gds.
  define buffer buf_prod-bc for ub.prod-bc.

  if not avail X_goods then return no-apply.

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
    'actn_object-weight-code_update':U
    {&cntxt-object}
    v-chk-act-host-code
    p-obj-type
    p-obj-code
    0
    X_goods.grp-code
    0
    true
    glog
  }

  if not glog then return no-apply.

    gds-rec = recid (X_goods).
    { gbl/gdsbcode.i X_goods.gds-code ? r-bar-code no-error}

    run ref/prod-cds.w (
                     input parparentproc
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input  "code-all":U
                    ,input X_goods.gds-code
                    ,input r-bar-code
                    ,output ref-list /* список рекидов */).
    if ref-list <> "" then do:
      glog = no.
      message
      "Вы действительно хотите поменять текущий весовой код для товара?"   skip
      "(После замены данный товар на весах будет взвешиваться с новым кодом)"
      view-as alert-box QUESTION buttons YEs-no update gLog.
      if not glog then return no-apply.
      { gbl/objdbnum.i X_gds-obj.obj-type X_gds-obj.obj-code v-obj-db-num }
      find first buf_scales-gds No-LOCK WHERE
                 buf_scales-gds.b-code = r-bar-code
            and buf_scales-gds.db-num = v-obj-db-num
                  No-ERROR.
      if avail buf_scales-gds then do:
        message "Товар имеется на весах"  skip
                "смена текущего весового кода невозможна"
        view-as alert-box ERROR.
          return no-apply.
      end.
      find first buf_prod-bc No-LOCK WHERE
                  recid(buf_prod-bc) = integer(ref-list) No-ERROR.
      if error-status:error then return no-apply.
      if buf_prod-bc.bc-on = false then do:
        message
        "Данный весовой код выключен" skip
        "смена весового кода невозможна"
        view-as alert-box ERROR.
        return no-apply.
      end.
      run proc-b-chg in this-procedure ( input X_goods.gds-code
                                       , input X_gds-obj.obj-type
                                       , input X_gds-obj.obj-code
                                       , buffer buf_prod-bc) no-error.
      if error-status:error then do:
          message "Смена текущего весового кода не удалась"
          view-as alert-box ERROR.
          return no-apply.
      end.
      run openbr in this-procedure ( input yes, input no, input '':U).
      reposition br-gds to recid gds-rec no-error.
      APPLY "ENTRY" to br-gds.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-code Dialog-Frame
ON CHOOSE OF B-code IN FRAME Dialog-Frame /* Коды */
DO:
   if code-option = "" then do:
    run gbl/pop-up.p ( input self:handle, input no) no-error.
    if error-status:error then return no-apply.
  end.
 if code-option = "" then return no-apply.
 run proc-b-code in this-procedure ( input-output code-option, buffer X_goods) no-error.
 if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-scales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-scales Dialog-Frame
ON CHOOSE OF B-scales IN FRAME Dialog-Frame /* Весы */
DO:
define variable r-bar-code like ub.bar-code.b-code no-undo.
define variable gds-rec as recid no-undo .
  if not avail X_goods then return no-apply.
  { gbl/gdsbcode.i X_goods.gds-code ? r-bar-code no-error}
  gds-rec = recid(X_goods).
   run ref/scgdssc.w (
                  input parparentproc
                 ,input v-cntxt-db-num-obj
                 ,input r-bar-code
                 ,input (if avail X_gds-obj then X_gds-obj.obj-type else p-obj-type)
                 ,input (if avail X_gds-obj then X_gds-obj.obj-code else p-obj-code)).
  run openbr in this-procedure ( input yes, input no, input '':U).
  reposition br-gds to recid gds-rec no-error.
  APPLY "ENTRY" to br-gds.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run init-flt in this-procedure no-error.
  if error-status:error then return no-apply.
    DO on stop undo, leave:
        run gbl/filter.w ( input parparentproc
                         , input (filter-point + {&delim-par} + filter-label)
                         , input tbl
                         , input join-tbl
                         , input fld
                         , input lab
                         , input spr
                         , input dim).
        RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    END .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_all Dialog-Frame
ON CHOOSE OF MENU-ITEM m_all /* Все */
DO:
  assign
  code-option = "all":U.
  run proc-b-code  in this-procedure ( input-output code-option, buffer X_goods) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_Prod-bc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_Prod-bc Dialog-Frame
ON CHOOSE OF MENU-ITEM m_Prod-bc /* Весовые */
DO:
    assign
  code-option = "scales-all":U.
  run proc-b-code in this-procedure ( input-output code-option, buffer X_goods) no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-mode Dialog-Frame
ON VALUE-CHANGED OF RS-mode IN FRAME Dialog-Frame
DO:
define variable gds-rec as recid no-undo .
  gds-rec = recid(X_goods).
  assign RS-MODE.
  Run MyEnable in this-procedure .
  Run OpenBr in this-procedure ( input yes, input no, input '':U).
  reposition br-gds to recid gds-rec no-error.
  APPLY "ENTRY" to br-gds.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-gds
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/setfltnm.i }

{ ref/scgdssch.i }
end.


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/f2.i br-gds " " " " parparentproc }
{ gbl/brwrefre.i "v-doc-rec = recid(X_goods). Run openbr in this-procedure ( input yes, input no, input '':U). reposition br-gds to recid(v-doc-rec). v-doc-rec = ? . " }
{ gbl/brwrepos.i
&line-num=5 }

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = " X_goods.artic "
  &sort-clmn_2    = " X_goods.gds-code "
  &sort-clmn_3    = " X_goods.gds-name "
  &sort-clmn_4    = " X_goods.grp-name "
  &open-query     = " run OpenBr in this-procedure ( input yes, input no, input '':U). "
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U). "
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }
  if v-cntxt-db-num-obj <> v-cntxt-db-num then do:
    message
    substitute("Нельзя просматривать Список весовых товаров магазина в чужой БД&1" +
               "БД текущего объекта &2, текущая БД  &3"
               , {&new-line}
               , v-cntxt-db-num-obj
               , v-cntxt-db-num)
    view-as alert-box error .
    return.
  end.

  assign
  X_gds-obj-attr.attr-value:read-only in browse {&BROWSE-NAME} = true.
  ASSIGN b-code:MENU-MOUSE = 1.
  ASSIGN
  Rs-MODE:radio-buttons = "Факт" + {&comma-char} + {&g___object} + {&comma-char} + "Все" + {&comma-char} + {&all}.
  rs-mode = p-mode.

  { str/sclspref.i varscales-pref varpgscales-pref }

  RUN Myenable in this-procedure .
  Run OpenBr in this-procedure ( input yes, input no, input '':U).
  { gbl/mv-clmn.i
  &ext-col = 8
  &frame-name = "{&frame-name}"
  &browse-name = "br-gds"
  &start-column = "{&num-locked-columns-br-list} + 1"
  &prev-order-column_1 = "'1,2,3,4,5,6,7,8'"
  &prev-order-column-condition_1 = " rs-mode = {&g___object} "
  &prev-order-column_1 = "'1,2,3,4,5,6,7,8'"
   &prev-order-column-condition_1 = " rs-mode = {&all} "
   }


  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

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
  DISPLAY loc-name loc-code loc-art a-n-c RS-mode
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-scales B-code B-chg B-sch B-Help loc-name loc-code loc-art
         a-n-c RS-mode BR-gds
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-flt Dialog-Frame
PROCEDURE init-flt :
assign
tbl = 'goods'
join-tbl = "X_goods"
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('artic', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-name', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('engl-name', 'Название по-английски', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prod-type{&delim-flt}prod-code', 'Производитель', 'cli', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('unit-base', '', 'unit', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('unit-cli', '', 'unit', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('grp-name', '', 'gdsgrp', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prt-root', 'Шкала', 'prt', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('increase-pc', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('qnty-cart', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('wt-cart', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('okdp', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('destin', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sert', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('struct', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sort', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('deadline', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('negative-rest', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cost-calc', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('gds-type', 'Услуга-товар', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tnved', 'Код ТНВЭД', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('nationality', '', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('unit-cst', 'Таможенная единица', 'unit', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('alpha1', 'Код страны изготовления', 'country', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('normal-wastage', 'Норма естест.убыли', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('normal-waste', 'Норма отходов', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('min-rate', 'Min кол-во в штуке', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('max-rate', 'Max кол-во в штуке', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
loc-art = "".
DISPLAY
a-n-c
WITH FRAME {&frame-name} .
ENABLE
b-quit
B-scales
B-code
B-sch
B-Help
a-n-c
BR-gds
b-chg when (v-cntxt-db-num-obj = v-cntxt-db-num)
RS-mode
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
assign
a-n-c = "art":U.
hide loc-art
in frame {&frame-name}
loc-name
loc-code in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ( input "Ждите...").
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

&scop flt-open-open-query OPEN QUERY br-gds FOR EACH X_goods No-LOCK

&scop flt-open-dyn_open-query FOR EACH X_goods No-LOCK

&scop flt-open-query-handle QUERY br-gds:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition




CASE RS-mode:
    when {&g___object} then do:

&scop flt-open-open-query-tail        , FIRST X_units No-LOCK WHERE X_units.unit-name = X_goods.unit-base AND ~
                                      LOOKUP({&weight}, X_units.type) > 0, ~
  FIRST X_gds-obj WHERE X_gds-obj.gds-code = X_goods.gds-code ~
  AND X_gds-obj.obj-type = p-obj-type ~
  AND X_gds-obj.obj-code = p-obj-code NO-LOCK, ~
  FIRST X_gds-obj-attr WHERE X_gds-obj-attr.gds-code = X_goods.gds-code ~
  AND X_gds-obj-attr.obj-type = X_gds-obj.obj-type ~
  AND X_gds-obj-attr.obj-code = X_gds-obj.obj-code ~
      AND X_gds-obj-attr.attr-code = {&attr-scales-code-o} OUTER-JOIN  NO-LOCK


&scop flt-open-dyn_open-query-tail     substitute('   , FIRST X_units No-LOCK WHERE X_units.unit-name = X_goods.unit-base AND ~
                                      LOOKUP(&1&5&1, X_units.type) > 0, ~
  FIRST X_gds-obj WHERE X_gds-obj.gds-code = X_goods.gds-code ~
  AND X_gds-obj.obj-type = &1&2&1 ~
  AND X_gds-obj.obj-code = &3 NO-LOCK, ~
  FIRST X_gds-obj-attr WHERE X_gds-obj-attr.gds-code = X_goods.gds-code ~
  AND X_gds-obj-attr.obj-type = X_gds-obj.obj-type ~
  AND X_gds-obj-attr.obj-code = X_gds-obj.obj-code ~
      AND X_gds-obj-attr.attr-code = &1&4&1 OUTER-JOIN  NO-LOCK', ~{&double-quote~}, p-obj-type, p-obj-code, {&attr-scales-code-o}, {&weight})


        ASSIGN
        frame {&frame-name}:TITLE = "ВЕСОВЫЕ ТОВАРЫ МАГАЗИНА " + p-obj-type + {&space-char} + string(p-obj-code)
        filter-point = filter-point0 + RS-mode
        filter-label = substitute("&1 один магазин", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind = "  "
            &by = "  "
          }


    end.
    otherwise do:

&scop flt-open-open-query-tail        , FIRST X_units No-LOCK WHERE X_units.unit-name = X_goods.unit-base AND ~
                                       LOOKUP({&weight}, X_units.type) > 0, ~
  FIRST X_gds-obj WHERE X_gds-obj.gds-code = X_goods.gds-code ~
  AND X_gds-obj.obj-type = p-obj-type ~
  AND X_gds-obj.obj-code = p-obj-code OUTER-JOIN NO-LOCK, ~
  FIRST X_gds-obj-attr WHERE X_gds-obj-attr.gds-code = X_goods.gds-code ~
  AND X_gds-obj-attr.obj-type = X_gds-obj.obj-type ~
  AND X_gds-obj-attr.obj-code = X_gds-obj.obj-code ~
      AND X_gds-obj-attr.attr-code = {&attr-scales-code-o} OUTER-JOIN  NO-LOCK

&scop flt-open-dyn_open-query-tail      substitute('  , FIRST X_units No-LOCK WHERE X_units.unit-name = X_goods.unit-base AND ~
                                       LOOKUP(&1&5&1, X_units.type) > 0, ~
  FIRST X_gds-obj WHERE X_gds-obj.gds-code = X_goods.gds-code ~
  AND X_gds-obj.obj-type = &1&2&1 ~
  AND X_gds-obj.obj-code = &3 OUTER-JOIN NO-LOCK, ~
  FIRST X_gds-obj-attr WHERE X_gds-obj-attr.gds-code = X_goods.gds-code ~
  AND X_gds-obj-attr.obj-type = X_gds-obj.obj-type ~
  AND X_gds-obj-attr.obj-code = X_gds-obj.obj-code ~
      AND X_gds-obj-attr.attr-code = &1&4&1 OUTER-JOIN  NO-LOCK', ~{&double-quote~}, p-obj-type, p-obj-code, {&attr-scales-code-o}, {&weight})



        ASSIGN
        frame {&frame-name}:TITLE = "ВСЕ ВЕСОВЫЕ ТОВАРЫ "
        filter-point = filter-point0 + RS-mode
        filter-label = substitute("&1", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " TRUE "
            &use-ind = "  "
            &by = "  "
          }
    end.


END CASE.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO BR-GDS.
APPLY "ENTRY" TO BR-GDS.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
DEFINE INPUT PARAMETER p-gds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER p-obj-type like ub.gds-obj.obj-type no-undo.
DEFINE INPUT PARAMETER p-obj-code like ub.gds-obj.obj-code no-undo.
define parameter buffer buf_prod-bc for ub.prod-bc.

define variable r-bar-code as integer no-undo .
define buffer loc-gds-obj-attr for ub.gds-obj-attr.

/*проверим это правильный код*/
/*bar-code для prod-bc должне быть основным кодом*/
{ gbl/gdsbcode.i X_goods.gds-code ? r-bar-code no-error}
if r-bar-code <> buf_prod-bc.b-code then do:
  message
  "Выбран НЕВЕРНЫЙ ДопБК"
  view-as alert-box error .
  return no-apply.
end.

run gdsoattr-write in this-procedure (
    input p-gds-code,
    input p-obj-type,
    input P-obj-code,
    input {&attr-scales-code-o},
    input string(integer(buf_prod-bc.b-str), "99999")
    ) no-error.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-code Dialog-Frame
PROCEDURE proc-b-code :
DEFINE INPUT-OUTPUT PARAMETER loc-code-option as character no-undo.
DEFINE PARAMETER buffer loc-goods for ub.goods.
define variable ref-list as character no-undo.

define variable r-bar-code like ub.bar-code.b-code no-undo.
  if not avail loc-goods then return no-apply.
    gds-rec = recid (loc-goods).
    { gbl/gdsbcode.i loc-goods.gds-code ? r-bar-code no-error }


CASE loc-code-option:
  when "ALL":U then do:
    run ref/alt-bc.w (
                  input parparentproc
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input  r-bar-code) no-error.

  end.
  when "scales-all" then do:
    run ref/prod-cds.w (
                              input parparentproc
                            ,input p-obj-type
                            ,input p-obj-code
                            ,input  "code-current":U
                            ,input  loc-goods.gds-code
                            ,input  r-bar-code
                            ,output ref-list /* список рекидов */).

  end.
end case.
code-option = "".




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME