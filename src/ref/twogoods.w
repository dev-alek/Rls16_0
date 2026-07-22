&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_gds-obj FOR ub.gds-obj.
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE BUFFER X_parts FOR ub.parts.
DEFINE BUFFER X_units FOR ub.units.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Товары с двумя ед измерения на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/14/05
Author: Bakhtadze Natalya
Creation date: 09/14/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode  as character no-undo .
define input parameter loc-store-type like ub.clients.obj-type no-undo.
define input parameter loc-store-code like ub.clients.obj-code no-undo.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Товары с двумя ед измерения на объекте" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }

define variable filter-point as character no-undo init "twogoods" .
define variable filter-point0 as character no-undo init "twogoods" .
define variable filter-label as character no-undo init "Товары_с_2_ед_изм" .
define variable filter-label0 as character no-undo init "Товары_с_2_ед_изм" . .

define variable sort-column-name as character no-undo .
define variable gds-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .

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
&Scoped-define INTERNAL-TABLES X_gds-obj X_goods X_units X_parts

/* Definitions for BROWSE BR-gds                                        */
&Scoped-define FIELDS-IN-QUERY-BR-gds is-case(buffer X_gds-obj) ~
is-stuck(buffer X_gds-obj) X_goods.artic X_goods.gds-name X_units.unit-name ~
X_goods.unit-cli X_goods.prod-type + string(X_goods.prod-code) ~
X_goods.min-rate X_goods.max-rate X_gds-obj.free-qnty X_gds-obj.fact-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-gds
&Scoped-define QUERY-STRING-BR-gds FOR EACH X_gds-obj NO-LOCK, ~
      EACH X_goods WHERE X_goods.gds-code = X_gds-obj.gds-code NO-LOCK, ~
      EACH X_units WHERE X_units.unit-name = X_goods.unit-base ~
  AND lookup({&twounit}, X_units.type) > 0 NO-LOCK, ~
      EACH X_parts WHERE X_parts.artic = X_gds-obj.artic ~
  AND X_parts.prod-type = X_gds-obj.prod-type ~
  AND X_parts.prod-code = X_gds-obj.prod-code ~
  AND X_parts.obj-type = X_gds-obj.obj-type ~
  AND X_parts.obj-code = X_gds-obj.obj-code ~
      AND X_parts.out-code = {&free-code} ~
  NO-LOCK
&Scoped-define OPEN-QUERY-BR-gds OPEN QUERY BR-gds FOR EACH X_gds-obj NO-LOCK, ~
      EACH X_goods WHERE X_goods.gds-code = X_gds-obj.gds-code NO-LOCK, ~
      EACH X_units WHERE X_units.unit-name = X_goods.unit-base ~
  AND lookup({&twounit}, X_units.type) > 0 NO-LOCK, ~
      EACH X_parts WHERE X_parts.artic = X_gds-obj.artic ~
  AND X_parts.prod-type = X_gds-obj.prod-type ~
  AND X_parts.prod-code = X_gds-obj.prod-code ~
  AND X_parts.obj-type = X_gds-obj.obj-type ~
  AND X_parts.obj-code = X_gds-obj.obj-code ~
      AND X_parts.out-code = {&free-code} ~
  NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-gds X_gds-obj X_goods X_units X_parts
&Scoped-define FIRST-TABLE-IN-QUERY-BR-gds X_gds-obj
&Scoped-define SECOND-TABLE-IN-QUERY-BR-gds X_goods
&Scoped-define THIRD-TABLE-IN-QUERY-BR-gds X_units
&Scoped-define FOURTH-TABLE-IN-QUERY-BR-gds X_parts


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-parts B-reshparts B-sch B-Help ~
rs-action BR-gds for-prod-name for-gds-code for-sort
&Scoped-Define DISPLAYED-OBJECTS rs-action for-prod-name for-gds-code ~
for-sort

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD is-case Dialog-Frame
FUNCTION is-case RETURNS LOGICAL
  ( buffer loc-gds-obj for X_gds-obj  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD is-stuck Dialog-Frame
FUNCTION is-stuck RETURNS LOGICAL
  ( buffer loc-gds-obj for X_gds-obj )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD Prod-name Dialog-Frame
FUNCTION Prod-name RETURNS CHARACTER
  ( input p-prod-type as character, input p-prod-code as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-parts
     LABEL "&Коробки"
     SIZE 10 BY 1.

DEFINE BUTTON B-reshparts
     LABEL "&Штуки"
     SIZE 10 BY 1.

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE VARIABLE for-gds-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14.25 BY 1 NO-UNDO.

DEFINE VARIABLE for-prod-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 73.88 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE for-sort AS CHARACTER FORMAT "X(30)":U
      VIEW-AS TEXT
     SIZE 16.63 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-action AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Неразбитые партии", "split",
"Штуки", "fuse"
     SIZE 50.38 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-gds FOR
      X_gds-obj,
      X_goods,
      X_units,
      X_parts SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-gds Dialog-Frame _STRUCTURED
  QUERY BR-gds NO-LOCK DISPLAY
      is-case(buffer X_gds-obj) COLUMN-LABEL "Кор-ки" FORMAT "+/":U
      is-stuck(buffer X_gds-obj) COLUMN-LABEL "Штуки" FORMAT "+/":U
      X_goods.artic FORMAT "X(16)":U
      X_goods.gds-name FORMAT "X(25)":U
      X_units.unit-name COLUMN-LABEL "Учет!ед.изм." FORMAT "X(3)":U
      X_goods.unit-cli COLUMN-LABEL "Ед.изм.!п-ка" FORMAT "X(3)":U
      X_goods.prod-type + string(X_goods.prod-code) COLUMN-LABEL "Пр-ль" FORMAT "X(12)":U
      X_goods.min-rate COLUMN-LABEL "Мин. кол-во в шт." FORMAT ">>,>>9.999":U
      X_goods.max-rate COLUMN-LABEL "Макс. кол-во в шт" FORMAT ">>,>>9.999":U
      X_gds-obj.free-qnty FORMAT "->>,>>>,>>9.999":U
      X_gds-obj.fact-qnty FORMAT "->>,>>>,>>9.999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 16.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     B-parts AT ROW 1 COL 21
     B-reshparts AT ROW 1 COL 31
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     rs-action AT ROW 5 COL 2.63 NO-LABEL
     BR-gds AT ROW 6.08 COL 1.88
     for-prod-name AT ROW 2.5 COL 10.13 NO-LABEL
     for-gds-code AT ROW 2.5 COL 82.75 COLON-ALIGNED NO-LABEL
     for-sort AT ROW 3.79 COL 13.38 COLON-ALIGNED NO-LABEL
     "Пр-ль:" VIEW-AS TEXT
          SIZE 7.25 BY 1 AT ROW 2.5 COL 1.63
     "Сорт/Проба:" VIEW-AS TEXT
          SIZE 11.75 BY 1 AT ROW 3.79 COL 2.13
     SPACE(86.11) SKIP(18.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары с 2 ед изм"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_gds-obj B "?" ? ub gds-obj
      TABLE: X_goods B "?" ? ub goods
      TABLE: X_parts B "?" ? ub parts
      TABLE: X_units B "?" ? ub units
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-gds rs-action Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BR-gds:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* SETTINGS FOR FILL-IN for-prod-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-gds
/* Query rebuild information for BROWSE BR-gds
     _TblList          = "ub.X_gds-obj,ub.X_goods WHERE ub.X_gds-obj ...,ub.X_units WHERE ub.X_goods ...,ub.X_parts WHERE ub.X_gds-obj ..."
     _Options          = "NO-LOCK"
     _JoinCode[2]      = "X_goods.gds-code = X_gds-obj.gds-code"
     _JoinCode[3]      = "X_units.unit-name = X_goods.unit-base
  AND lookup({&twounit}, X_units.type) > 0"
     _JoinCode[4]      = "X_parts.artic = X_gds-obj.artic
  AND X_parts.prod-type = X_gds-obj.prod-type
  AND X_parts.prod-code = X_gds-obj.prod-code
  AND X_parts.obj-type = X_gds-obj.obj-type
  AND X_parts.obj-code = X_gds-obj.obj-code"
     _Where[4]         = "X_parts.out-code = {&free-code}
 "
     _FldNameList[1]   > "_<CALC>"
"is-case(buffer X_gds-obj)" "Кор-ки" "+/" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"is-stuck(buffer X_gds-obj)" "Штуки" "+/" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   = Temp-Tables.X_goods.artic
     _FldNameList[4]   > Temp-Tables.X_goods.gds-name
"X_goods.gds-name" ? "X(25)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > Temp-Tables.X_units.unit-name
"X_units.unit-name" "Учет!ед.изм." ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > Temp-Tables.X_goods.unit-cli
"X_goods.unit-cli" "Ед.изм.!п-ка" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > "_<CALC>"
"X_goods.prod-type + string(X_goods.prod-code)" "Пр-ль" "X(12)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > Temp-Tables.X_goods.min-rate
"X_goods.min-rate" "Мин. кол-во в шт." ">>,>>9.999" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > Temp-Tables.X_goods.max-rate
"X_goods.max-rate" "Макс. кол-во в шт" ">>,>>9.999" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > Temp-Tables.X_gds-obj.free-qnty
"X_gds-obj.free-qnty" ? "->>,>>>,>>9.999" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   > Temp-Tables.X_gds-obj.fact-qnty
"X_gds-obj.fact-qnty" ? "->>,>>>,>>9.999" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE BR-gds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON RETURN OF FRAME Dialog-Frame /* Товары с 2 ед изм */
DO:
  APPLY "DEFAULT-ACTION" to br-gds.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары с 2 ед изм */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-parts Dialog-Frame
ON CHOOSE OF B-parts IN FRAME Dialog-Frame /* Коробки */
DO:
define variable v-doc-rec as recid no-undo .
    if avail X_gds-obj then do:
    v-doc-rec = recid(X_gds-obj).
    run ref/twoparts.w (
    input parparentproc,
    input "split":U,
    input p-mode,
    input X_gds-obj.artic,
    input X_gds-obj.prod-type,
    input X_gds-obj.prod-code,
    input X_gds-obj.obj-type,
    input X_gds-obj.obj-code) no-error.

  run openbr in this-procedure ( input yes, input no, input '':U).
  reposition  {&browse-name} to recid v-doc-rec no-error.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-reshparts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-reshparts Dialog-Frame
ON CHOOSE OF B-reshparts IN FRAME Dialog-Frame /* Штуки */
DO:
define variable v-doc-rec as recid no-undo .
    if avail X_gds-obj then do:
    v-doc-rec = recid(X_gds-obj).
    run ref/twoparts.w (
    input parparentproc,
    input "fuse":U,
    input p-mode,
    input X_gds-obj.artic,
    input X_gds-obj.prod-type,
    input X_gds-obj.prod-code,
    input X_gds-obj.obj-type,
    input X_gds-obj.obj-code) no-error.

  run openbr in this-procedure ( input yes, input no, input '':U).
  reposition {&browse-name} to recid v-doc-rec no-error.
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
  tbl = 'gds-obj'
  join-tbl = 'X_gds-obj'
  fld = '':U
  spr = '':U
  lab = '':U
  dim = '0':U
  .
  run fltfield-add in this-procedure('artic', 'Артикул', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('gds-code', 'Код товара', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('prod-type{&delim-flt}prod-code', 'Производитель', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('free-qnty', 'Своб.кол-во', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-qnty', 'Факт.кол-во', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  DO on stop undo, leave:
      run gbl/filter.w ( input parparentproc
                         ,input (filter-point + {&delim-par} + filter-label)
                         ,input tbl
                         ,input join-tbl
                         ,input fld
                         ,input lab
                         ,input spr
                         ,input dim).
      RUN OpenBr in this-procedure ( input yes, input no, input '':U).
  END .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-gds
&Scoped-define SELF-NAME BR-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-gds Dialog-Frame
ON DEFAULT-ACTION OF BR-gds IN FRAME Dialog-Frame
DO:
    if avail X_gds-obj then
        apply "CHOOSE":U to b-parts.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-gds Dialog-Frame
ON RETURN OF BR-gds IN FRAME Dialog-Frame
DO:
  APPLY "DEFAULT-ACTION" to br-gds.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-gds Dialog-Frame
ON VALUE-CHANGED OF BR-gds IN FRAME Dialog-Frame
DO:
  if avail X_gds-obj then do:
      assign gds-rec = recid(X_goods).
      for-prod-name = prod-name(X_goods.prod-type, x_goods.prod-code).
      for-gds-code = X_goods.gds-code.
      for-sort = X_goods.sort.

  end.
  else
  assign
  gds-rec = ?
  for-prod-name = ""
  for-gds-code = ?
  for-sort = ''
  .
  display
  for-prod-name
  for-gds-code
  for-sort
  with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-action
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-action Dialog-Frame
ON VALUE-CHANGED OF rs-action IN FRAME Dialog-Frame
DO:
  assign rs-action.
  case rs-action:
    when "all":U then do:
        ENABLE
        b-parts
        b-reshparts
        with frame {&frame-name}.
    end.
    when "split":U then do:
        ENABLE
        b-parts
        with frame {&frame-name}.
        DISABLE
        b-reshparts
        with frame {&frame-name}.
    end.
    when "fuse":U then do:
        ENABLE
        b-reshparts
        with frame {&frame-name}.
        DISABLE
        b-parts
        with frame {&frame-name}.
    end.
  end case.
  run OpenBr in this-procedure ( input yes, input no, input '':U).
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
{ gbl/f2.i br-gds goods-recid get-goods-recid parparentproc }
{ gbl/setfltnm.i }
{ gbl/brwrefre.i "v-doc-rec = recid(X_gds-obj). Run Openbr in this-procedure ( input yes, input no, input '':U). reposition br-gds to recid v-doc-rec no-error. v-doc-rec = ?. " }
{ gbl/brwrepos.i
&line-num=5
}
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  apply "value-changed" to rs-action.
  Run OpenBr in this-procedure ( input yes, input no, input '':U).
  { gbl/mv-clmn.i
  &ext-col = 9
  &frame-name = "{&frame-name}"
  &browse-name = "br-gds"
  &start-column = "{&num-locked-columns-br-list} + 1"
  &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9'"
  &prev-order-column-condition_1 = " p-mode = {&g___object} "
  }
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

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
  DISPLAY rs-action for-prod-name for-gds-code for-sort
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-parts B-reshparts B-sch B-Help rs-action BR-gds for-prod-name
         for-gds-code for-sort
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-goods-recid Dialog-Frame
PROCEDURE get-goods-recid :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if avail X_gds-obj then
gds-rec = recid(X_goods).
else
gds-rec = ?.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  ENABLE B-exit B-sch B-Help BR-gds
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
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

&scop flt-open-open-query OPEN QUERY br-gds FOR EACH X_gds-obj NO-LOCK

&scop flt-open-dyn_open-query FOR EACH X_gds-obj NO-LOCK

&scop flt-open-query-handle QUERY br-gds:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-debug-file

&scop flt-open-waitfram yes


CASE p-mode:
    when {&g___object} then do:
        ASSIGN frame {&frame-name}:TITLE = "Товары с двумя ед.изм. на объекте " + loc-store-type + string(loc-store-code)
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Один объект", filter-label0)
        .
        case rs-action:
          when "all":U then do:
            &scop flt-open-open-query-tail , FIRST X_goods NO-LOCK WHERE X_goods.gds-code = X_gds-obj.gds-code,  ~
            FIRST X_units WHERE X_units.unit-name = X_goods.unit-base AND LOOKUP({&twounit}, X_units.type) > 0, ~
            FIRST X_parts No-LOCK WHERE X_parts.artic = X_gds-obj.artic AND X_parts.prod-type = X_gds-obj.prod-type AND ~
            X_parts.prod-code = X_gds-obj.prod-code AND X_parts.obj-type = X_gds-obj.obj-type AND ~
            X_parts.obj-code = X_gds-obj.obj-code AND X_parts.out-code = {&free-code}

            &scop flt-open-dyn_open-query-tail substitute(', FIRST X_goods NO-LOCK WHERE X_goods.gds-code = X_gds-obj.gds-code,  ~
            FIRST X_units WHERE X_units.unit-name = X_goods.unit-base AND LOOKUP(&1&2&1, X_units.type) > 0, ~
            FIRST X_parts No-LOCK WHERE X_parts.artic = X_gds-obj.artic AND X_parts.prod-type = X_gds-obj.prod-type AND ~
            X_parts.prod-code = X_gds-obj.prod-code AND X_parts.obj-type = X_gds-obj.obj-type AND ~
            X_parts.obj-code = X_gds-obj.obj-code AND X_parts.out-code = &1&3&1  ', ~{&double-quote~}, {&twounit}, {&free-code})


            { gbl/fltopend.i
              &where-cond = " X_gds-obj.obj-type = loc-store-type AND X_gds-obj.obj-code = loc-store-code and X_gds-obj.fact-qnty <> 0 "
              &dyn_where-cond = " substitute('X_gds-obj.obj-type = &1&2&1 AND X_gds-obj.obj-code = &3 and X_gds-obj.fact-qnty <> 0 ' ~
                                   , ~{&double-quote~}, loc-store-type, loc-store-code)"
              &use-ind = " "
              &by = "  "
            }
          end.
          when "split":U then do:
            &scop flt-open-open-query-tail , FIRST X_goods NO-LOCK WHERE X_goods.gds-code = X_gds-obj.gds-code,  ~
            FIRST X_units WHERE X_units.unit-name = X_goods.unit-base AND LOOKUP({&twounit}, X_units.type) > 0, ~
            FIRST X_parts No-LOCK WHERE X_parts.artic = X_gds-obj.artic AND X_parts.prod-type = X_gds-obj.prod-type AND ~
            X_parts.prod-code = X_gds-obj.prod-code AND X_parts.obj-type = X_gds-obj.obj-type AND ~
            X_parts.obj-code = X_gds-obj.obj-code AND X_parts.out-code = {&free-code} AND X_parts.cli-qnty > 1

            &scop flt-open-dyn_open-query-tail substitute(', FIRST X_goods NO-LOCK WHERE X_goods.gds-code = X_gds-obj.gds-code,  ~
            FIRST X_units WHERE X_units.unit-name = X_goods.unit-base AND LOOKUP(&1&2&1, X_units.type) > 0, ~
            FIRST X_parts No-LOCK WHERE X_parts.artic = X_gds-obj.artic AND X_parts.prod-type = X_gds-obj.prod-type AND ~
            X_parts.prod-code = X_gds-obj.prod-code AND X_parts.obj-type = X_gds-obj.obj-type AND ~
            X_parts.obj-code = X_gds-obj.obj-code AND X_parts.out-code = &1&3&1 AND X_parts.cli-qnty > 1', ~{&double-quote~}, {&twounit}, {&free-code})


            { gbl/fltopend.i
              &where-cond = " X_gds-obj.obj-type = loc-store-type AND X_gds-obj.obj-code = loc-store-code and X_gds-obj.fact-qnty <> 0 "
              &dyn_where-cond = " substitute('X_gds-obj.obj-type = &1&2&1 AND X_gds-obj.obj-code = &3 and X_gds-obj.fact-qnty <> 0 ' ~
                                  , {&double-quote}, loc-store-type, loc-store-code)"
              &use-ind = " "
              &by = "  "
            }
          end.
          when "fuse":U then do:
            &scop flt-open-open-query-tail , FIRST X_goods NO-LOCK WHERE X_goods.gds-code = X_gds-obj.gds-code,  ~
            FIRST X_units WHERE X_units.unit-name = X_goods.unit-base AND LOOKUP({&twounit}, X_units.type) > 0, ~
            FIRST X_parts No-LOCK WHERE X_parts.artic = X_gds-obj.artic AND X_parts.prod-type = X_gds-obj.prod-type AND ~
            X_parts.prod-code = X_gds-obj.prod-code AND X_parts.obj-type = X_gds-obj.obj-type AND ~
            X_parts.obj-code = X_gds-obj.obj-code AND X_parts.out-code = {&free-code} AND X_parts.cli-qnty = 1

            &scop flt-open-dyn_open-query-tail substitute(', FIRST X_goods NO-LOCK WHERE X_goods.gds-code = X_gds-obj.gds-code,  ~
            FIRST X_units WHERE X_units.unit-name = X_goods.unit-base AND LOOKUP(&1&2&1, X_units.type) > 0, ~
            FIRST X_parts No-LOCK WHERE X_parts.artic = X_gds-obj.artic AND X_parts.prod-type = X_gds-obj.prod-type AND ~
            X_parts.prod-code = X_gds-obj.prod-code AND X_parts.obj-type = X_gds-obj.obj-type AND ~
            X_parts.obj-code = X_gds-obj.obj-code AND X_parts.out-code = &1&3&1 AND X_parts.cli-qnty = 1', ~{&double-quote~}, {&twounit}, {&free-code})


            { gbl/fltopend.i
              &where-cond = " X_gds-obj.obj-type = loc-store-type AND X_gds-obj.obj-code = loc-store-code and X_gds-obj.fact-qnty <> 0 "
              &dyn_where-cond = " substitute('X_gds-obj.obj-type = &1&2&1 AND X_gds-obj.obj-code = &3 and X_gds-obj.fact-qnty <> 0 ' ~
                                , ~{&double-quote~}, loc-store-type, loc-store-code)"
              &use-ind = " "
              &by = "  "
            }
          end.
        end case.
    end.

END CASE.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-gds.
APPLY "ENTRY" TO br-gds.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION is-case Dialog-Frame
FUNCTION is-case RETURNS LOGICAL
  ( buffer loc-gds-obj for X_gds-obj  ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER LOC-PARTS FOR ub.parts.
  find FIRST loc-parts No-LOCK WHERE
             loc-parts.artic = loc-gds-obj.artic AND
             loc-parts.prod-type = loc-gds-obj.prod-type AND
             loc-parts.prod-code = loc-gds-obj.prod-code AND
             loc-parts.obj-type = loc-gds-obj.obj-type AND
             loc-parts.obj-code = loc-gds-obj.obj-code AND
             loc-parts.out-code = {&free-code} and
             LOC-PARTS.CLI-QNTY > 1 no-error.


  RETURN avail(loc-parts).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION is-stuck Dialog-Frame
FUNCTION is-stuck RETURNS LOGICAL
  ( buffer loc-gds-obj for X_gds-obj ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer loc-parts for ub.parts.
  find FIRST loc-parts No-LOCK WHERE
             loc-parts.artic = loc-gds-obj.artic AND
             loc-parts.prod-type = loc-gds-obj.prod-type AND
             loc-parts.prod-code = loc-gds-obj.prod-code AND
             loc-parts.obj-type = loc-gds-obj.obj-type AND
             loc-parts.obj-code = loc-gds-obj.obj-code AND
             loc-parts.out-code = {&free-code} and
             LOC-PARTS.CLI-QNTY = 1 no-error.

  RETURN avail(loc-parts).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION Prod-name Dialog-Frame
FUNCTION Prod-name RETURNS CHARACTER
  ( input p-prod-type as character, input p-prod-code as integer) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
FIND FIRST ub.clients no-LOCK where
           ub.clients.obj-type = p-prod-type AND
           ub.clients.obj-code = p-prod-code NO-ERROR.
  if avail ub.clients then
  return ub.clients.obj-name.
  else
  RETURN "".

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME