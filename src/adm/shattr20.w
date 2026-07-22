&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE TEMP-TABLE tt-trn-doc NO-UNDO LIKE ub.trn-doc.
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_store FOR ub.store.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина (thbj-attr) {&attr-rt-trn-doc}

Автор: Хныкин Павел Андреевич
Дата создания: 09/08/05
Author: Pavel Khnykin
Creation date: 09/08/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.clients.obj-code NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) {&attr-rt-trn-doc}".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
DEFINE VARIABLE v-old-attr-value AS CHARACTER NO-UNDO.
DEFINE BUFFER cli-buf FOR ub.clients .
define variable ref-rec as recid no-undo .
define variable s-list-mode as character no-undo .
define variable list-mode as character no-undo .
define variable s-doc-mode as character no-undo .
define variable doc-mode as character no-undo .
define variable s-doc-rec as recid no-undo .
define variable doc-rec as recid no-undo .
define variable s-line-rec as recid no-undo .
define variable line-rec as recid no-undo .
define variable s-gds-rec as recid no-undo .
define variable gds-rec as recid no-undo .
define variable s-prt-rec as recid no-undo .
define variable prt-rec as recid no-undo .
define variable line-mode as character no-undo .
define variable s-line-mode as character no-undo .
define variable ref-list as character no-undo .
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-trn-doc

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-trn-doc.wrkr tt-trn-doc.agnt ~
tt-trn-doc.boss 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-trn-doc.wrkr ~
tt-trn-doc.agnt tt-trn-doc.boss 
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-trn-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-trn-doc
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-trn-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-trn-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-trn-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-trn-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-trn-doc.wrkr tt-trn-doc.agnt ~
tt-trn-doc.boss 
&Scoped-define ENABLED-TABLES tt-trn-doc
&Scoped-define FIRST-ENABLED-TABLE tt-trn-doc
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help B-1 r-wrkr B-2 r-agnt ~
B-3 r-boss wrkr-name agnt-name boss-name 
&Scoped-Define DISPLAYED-FIELDS tt-trn-doc.wrkr tt-trn-doc.agnt ~
tt-trn-doc.boss 
&Scoped-define DISPLAYED-TABLES tt-trn-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-trn-doc
&Scoped-Define DISPLAYED-OBJECTS wrkr-name agnt-name boss-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-1 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-2 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-3 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-agnt 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc" 
     SIZE 3 BY .88.

DEFINE BUTTON r-boss 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc" 
     SIZE 3 BY .88.

DEFINE BUTTON r-wrkr 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc" 
     SIZE 3 BY .88.

DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "x(256)":U 
      VIEW-AS TEXT 
     SIZE 35 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE boss-name AS CHARACTER FORMAT "x(256)":U 
      VIEW-AS TEXT 
     SIZE 35 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "x(256)":U 
      VIEW-AS TEXT 
     SIZE 35 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR 
      tt-trn-doc SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 77.5
     B-1 AT ROW 2.25 COL 4 WIDGET-ID 80
     tt-trn-doc.wrkr AT ROW 2.25 COL 18.5 COLON-ALIGNED
          LABEL "К&ладовщик"
          VIEW-AS FILL-IN 
          SIZE 9.75 BY 1
     r-wrkr AT ROW 2.25 COL 30.63
     B-2 AT ROW 3.25 COL 4 WIDGET-ID 82
     tt-trn-doc.agnt AT ROW 3.25 COL 18.5 COLON-ALIGNED
          LABEL "И&сполнитель"
          VIEW-AS FILL-IN 
          SIZE 9.75 BY 1
     r-agnt AT ROW 3.25 COL 30.5
     B-3 AT ROW 4.25 COL 4 WIDGET-ID 84
     tt-trn-doc.boss AT ROW 4.25 COL 18.5 COLON-ALIGNED
          LABEL "&Менеджер"
          VIEW-AS FILL-IN 
          SIZE 9.75 BY 1
     r-boss AT ROW 4.25 COL 30.5
     wrkr-name AT ROW 2.25 COL 31.5 COLON-ALIGNED NO-LABEL
     agnt-name AT ROW 3.25 COL 31.5 COLON-ALIGNED NO-LABEL
     boss-name AT ROW 4.25 COL 31.5 COLON-ALIGNED NO-LABEL
     SPACE(12.87) SKIP(0.87)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Радиотерминал. Параметры документа по умолчанию"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: tt-trn-doc T "?" NO-UNDO ub trn-doc
      TABLE: X_shop B "?" ? ub shop
      TABLE: X_store B "?" ? ub store
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-trn-doc.agnt IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-trn-doc.boss IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-trn-doc.wrkr IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-trn-doc"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Радиотерминал. Параметры документа по умолчанию */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-trn-doc.agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.agnt Dialog-Frame
ON LEAVE OF tt-trn-doc.agnt IN FRAME Dialog-Frame /* Исполнитель */
DO:
  if input frame {&frame-name} tt-trn-doc.agnt <> tt-trn-doc.agnt then do:
    run local-psn-chk ("agnt", "leave").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.agnt Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-trn-doc.agnt IN FRAME Dialog-Frame /* Исполнитель */
OR RETURN OF tt-trn-doc.agnt IN FRAME {&frame-name} DO:
  run local-psn-chk ("agnt", "ret-mouse").
  apply "entry" to tt-trn-doc.agnt in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-1 Dialog-Frame
ON CHOOSE OF B-1 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-rt-trn-doc},
       "wrkr"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-2 Dialog-Frame
ON CHOOSE OF B-2 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-rt-trn-doc},
       "agnt"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-3 Dialog-Frame
ON CHOOSE OF B-3 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-rt-trn-doc},
       "boss"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-trn-doc.boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.boss Dialog-Frame
ON LEAVE OF tt-trn-doc.boss IN FRAME Dialog-Frame /* Менеджер */
DO:
  if input frame {&frame-name} tt-trn-doc.boss <> tt-trn-doc.boss then do:
    run local-psn-chk ("boss", "leave").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.boss Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-trn-doc.boss IN FRAME Dialog-Frame /* Менеджер */
OR RETURN OF tt-trn-doc.boss IN FRAME {&frame-name} DO:
  run local-psn-chk ("boss", "ret-mouse").
  apply "entry" to tt-trn-doc.boss in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-agnt Dialog-Frame
ON CHOOSE OF r-agnt IN FRAME Dialog-Frame /* r-acc */
DO:
  RUN local-psn-chk ("agnt", "button").
  apply "entry" to tt-trn-doc.agnt in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-boss Dialog-Frame
ON CHOOSE OF r-boss IN FRAME Dialog-Frame /* r-acc */
DO:
    RUN local-psn-chk ("boss", "button").
  apply "entry" to tt-trn-doc.boss in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-wrkr Dialog-Frame
ON CHOOSE OF r-wrkr IN FRAME Dialog-Frame /* r-acc */
DO:
  RUN local-psn-chk ("wrkr", "button").
  apply "entry" to tt-trn-doc.wrkr in FRAME {&FRAME-NAME}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-trn-doc.wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.wrkr Dialog-Frame
ON LEAVE OF tt-trn-doc.wrkr IN FRAME Dialog-Frame /* Кладовщик */
DO:
  if input frame {&frame-name} tt-trn-doc.wrkr <> tt-trn-doc.wrkr then do:
    run local-psn-chk ("wrkr", "leave").
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-trn-doc.wrkr Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-trn-doc.wrkr IN FRAME Dialog-Frame /* Кладовщик */
OR RETURN OF tt-trn-doc.wrkr IN FRAME {&frame-name} DO:
  run local-psn-chk ("wrkr", "ret-mouse").
  apply "entry" to tt-trn-doc.wrkr in frame {&frame-name}.
  return no-apply.
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


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
  IF p-mode <> {&lookup}
  and p-mode <> {&update} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-obj-type <> {&shop}
  and p-obj-type <> {&stock}
  and p-obj-type <> {&cmp}
  and p-obj-type <> '':U
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  if p-obj-type = {&shop} then do:
    FIND FIRST X_shop NO-LOCK WHERE X_shop.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_shop THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/objdbnum.i ~{&shop~} p-obj-code v-db-num }
    IF v-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.

    END.
  end.
  if p-obj-type = {&stock} then do:
    FIND FIRST X_store NO-LOCK WHERE X_store.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_store THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/objdbnum.i ~{&stock~} p-obj-code v-db-num }
    IF v-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    THEN DO:
        MESSAGE
        "Нельзя менять параметры склада в чужой БД" skip
        "склад принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
  end.
  if p-obj-type = {&cmp} then do:
    FIND FIRST X_sysconf NO-LOCK WHERE X_sysconf.host-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_sysconf THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять параметры ФИРМЫ в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  if p-obj-type = '':U then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-rt-trn-doc}
        AND   LOCKED_thbj-attr.prop-code = '':U NO-WAIT NO-ERROR.
     if locked locked_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ПАРАМЕТРЫ(АТРИБУТЫ) МАГАЗИНА занята"
        view-as alert-box error .
        undo, return error.
      end.
  END.
  ELSE DO:
      FIND FIRST LOCKED_thbj-attr no-LOCK WHERE
          LOCKED_thbj-attr.obj-type = p-obj-type
    AND   LOCKED_thbj-attr.obj-code = p-obj-code
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-rt-trn-doc}
    AND   LOCKED_thbj-attr.prop-code = '':U NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.
  end.
  RUN FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  RUN Myenable.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY wrkr-name agnt-name boss-name 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-trn-doc THEN 
    DISPLAY tt-trn-doc.wrkr tt-trn-doc.agnt tt-trn-doc.boss 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help B-1 tt-trn-doc.wrkr r-wrkr B-2 tt-trn-doc.agnt 
         r-agnt B-3 tt-trn-doc.boss r-boss wrkr-name agnt-name boss-name 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
DEFINE VARIABLE v-cli-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE VARIABLE v-cli-code LIKE ub.clients.obj-code NO-UNDO.
DEFINE VARIABLE v-obj-name LIKE ub.clients.obj-name NO-UNDO.
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
DEFINE BUFFER buf_clients FOR ub.clients.
FOR EACH tt-trn-doc:
  DELETE tt-trn-doc.
END.
FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.
CREATE tt-trn-doc.
run adm/shattri.p (
              input "init":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-rt-trn-doc}
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , input-output table-handle v-tth
            ) no-error .

if error-status:error
and not available locked_thbj-attr
then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr:
  ASSIGN
  v-entry = thbjattr_thbj-attr.prop-code.
  if v-entry = {&attr-rt-trn-doc_wrkr}
  then do:
    assign
    tt-trn-doc.wrkr = thbjattr_thbj-attr.property-value-integer
    tt-trn-doc.wrkr:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  end.
  if v-entry = {&attr-rt-trn-doc_agnt}
  then do:
    assign
    tt-trn-doc.agnt = thbjattr_thbj-attr.property-value-integer
    tt-trn-doc.agnt:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  end.
  if v-entry = {&attr-rt-trn-doc_boss}
  then do:
    assign
    tt-trn-doc.boss = thbjattr_thbj-attr.property-value-integer
    tt-trn-doc.boss:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  end.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
end.
if tt-trn-doc.wrkr = 0 then tt-trn-doc.wrkr = ?.
if tt-trn-doc.agnt = 0 then tt-trn-doc.agnt = ?.
if tt-trn-doc.boss = 0 then tt-trn-doc.boss = ?.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-psn-chk Dialog-Frame 
PROCEDURE local-psn-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = {&attr-rt-trn-doc_wrkr} and p-action = "ret-mouse" then do:
   { str/psn-chk.i wrkr ret-mouse tt-trn-doc }
end.
if p-man = {&attr-rt-trn-doc_wrkr} and p-action = "button" then do:
   { str/psn-chk.i wrkr button tt-trn-doc }
end.
if p-man = {&attr-rt-trn-doc_wrkr} and p-action = "leave" then do:
   { str/psn-chk.i wrkr leave tt-trn-doc }
end.
if p-man = {&attr-rt-trn-doc_agnt} and p-action = "ret-mouse" then do:
   { str/psn-chk.i agnt ret-mouse tt-trn-doc }
end.
if p-man = {&attr-rt-trn-doc_agnt} and p-action = "button" then do:
   { str/psn-chk.i agnt button tt-trn-doc }
end.
if p-man = {&attr-rt-trn-doc_agnt} and p-action = "leave" then do:
   { str/psn-chk.i agnt leave tt-trn-doc }
end.
if p-man = {&attr-rt-trn-doc_boss} and p-action = "ret-mouse" then do:
   { str/psn-chk.i boss ret-mouse tt-trn-doc }
end.
if p-man = {&attr-rt-trn-doc_boss} and p-action = "button" then do:
   { str/psn-chk.i boss button tt-trn-doc }
end.
if p-man = {&attr-rt-trn-doc_boss} and p-action = "leave" then do:
   { str/psn-chk.i boss leave tt-trn-doc }
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
ASSIGN
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code)
v-tab-order = "wrkr,r-wrkr,agnt,r-agnt,boss,r-boss".
find first tt-trn-doc.
{ str/psn-chk.i wrkr on tt-trn-doc }
{ str/psn-chk.i agnt on tt-trn-doc }
{ str/psn-chk.i boss on tt-trn-doc }
DISPLAY
tt-trn-doc.wrkr
tt-trn-doc.agnt
tt-trn-doc.boss
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
    b-1
    b-2
    b-3
    B-Help
tt-trn-doc.wrkr WHEN p-mode = {&UPDATE}
tt-trn-doc.agnt WHEN p-mode = {&UPDATE}
tt-trn-doc.boss WHEN p-mode = {&UPDATE}
r-wrkr WHEN p-mode = {&UPDATE}
r-agnt WHEN p-mode = {&UPDATE}
r-boss WHEN p-mode = {&UPDATE}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.

IF p-mode = {&LOOKUP} THEN DO:
    HIDE
    b-exit
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:LABEL = "&Выход"
    .
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .

IF p-mode = {&LOOKUP} THEN do:
  RETURN ERROR.
end.
ASSIGN
FRAME {&FRAME-NAME}
tt-trn-doc.wrkr
tt-trn-doc.agnt
tt-trn-doc.boss
tt-trn-doc.wrkr = if tt-trn-doc.wrkr = ? then 0 else tt-trn-doc.wrkr
tt-trn-doc.agnt = if tt-trn-doc.agnt = ? then 0 else tt-trn-doc.agnt
tt-trn-doc.boss = if tt-trn-doc.boss = ? then 0 else tt-trn-doc.boss
.
assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
  end.
  wh = wh:next-sibling.
end.
v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code:
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
/*проверим корректность*/
run adm/shattri.p (
              input "check":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-rt-trn-doc}
            , INPUT '':U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , input-output table-handle v-tth
            ) no-error .

if error-status:error then do:
  message
  "Некорректное значение ПАРАМЕТРОВ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
do TRANSACTION
on error undo, return error return-value
:
  RUN thbjattr_set-section IN THIS-PROCEDURE (
       input p-obj-type
      ,input p-obj-code
      ,input {&attr-rt-trn-doc}
      ,INPUT table thbjattr_thbj-attr
  ) NO-ERROR.
  IF ERROR-STATUS:error THEN do:
    MESSAGE ERROR-STATUS:get-message(1)  SKIP
    RETURN-VALUE
    VIEW-AS ALERT-BOX.
    UNDO, RETURN ERROR.
  END.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

