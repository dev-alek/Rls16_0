&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_wealth FOR ub.wealth.
DEFINE BUFFER locked_wth-par FOR ub.wth-par.
DEFINE TEMP-TABLE tt-wth-par NO-UNDO LIKE ub.wth-par.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка номинала материальной ценности

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input param pwth-code like ub.wth-par.wth-code no-undo.
define input param ppar-code like ub.wth-par.par-code no-undo.
define input param par-mode as char no-undo.
define output param p-rec as recid no-undo.



/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка номинала материальной ценности ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_units FOR ub.units.
DEFINE BUFFER buf_currency FOR ub.currency.
define buffer buf_wth-gds  for ub.wth-gds.
define buffer buf_goods    for ub.goods.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-wth-par.par-val tt-wth-par.par-rate ~
tt-wth-par.par-feat tt-wth-par.wth-code locked_wth-par.par-code
&Scoped-define ENABLED-TABLES tt-wth-par locked_wth-par
&Scoped-define FIRST-ENABLED-TABLE tt-wth-par
&Scoped-define SECOND-ENABLED-TABLE locked_wth-par
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-hist B-Help B-unit Bpar-feat
&Scoped-Define DISPLAYED-FIELDS tt-wth-par.par-val tt-wth-par.par-rate ~
tt-wth-par.par-feat tt-wth-par.wth-code locked_wth-par.par-code
&Scoped-define DISPLAYED-TABLES tt-wth-par locked_wth-par
&Scoped-define FIRST-DISPLAYED-TABLE tt-wth-par
&Scoped-define SECOND-DISPLAYED-TABLE locked_wth-par


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-unit
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON Bpar-feat
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04
     BGCOLOR 8 FGCOLOR 0 .

DEFINE VARIABLE Spar-feat AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEMS "Банкнота","Монета"
     SIZE 16.25 BY 1.5 NO-UNDO.

DEFINE VARIABLE Spar-unit AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 15.88 BY 2.04 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     b-quit AT ROW 1 COL 11.13
     B-hist AT ROW 1 COL 70
     B-Help AT ROW 1 COL 73
     tt-wth-par.par-val AT ROW 3.83 COL 25.5 COLON-ALIGNED
          LABEL "Номинал"
          VIEW-AS FILL-IN
          SIZE 13.63 BY 1
     tt-wth-par.par-rate AT ROW 5.33 COL 25.5 COLON-ALIGNED
          LABEL "Коэффициент"
          VIEW-AS FILL-IN
          SIZE 13.63 BY 1
     B-unit AT ROW 6.58 COL 44.5
     Spar-unit AT ROW 6.63 COL 27.5 NO-LABEL
     tt-wth-par.par-unit AT ROW 6.63 COL 25.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 13.63 BY 1
     tt-wth-par.par-feat AT ROW 8.88 COL 25.5 COLON-ALIGNED
          LABEL "Доп. признак"
          VIEW-AS FILL-IN
          SIZE 15.75 BY 1
     Bpar-feat AT ROW 9.04 COL 44.75
     Spar-feat AT ROW 10.08 COL 27.5 NO-LABEL
     tt-wth-par.wth-code AT ROW 1.08 COL 40.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10.13 BY 1
          FGCOLOR 4
     locked_wth-par.par-code AT ROW 2.46 COL 40.25 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10.5 BY 1
          FGCOLOR 4
     "Код номинала" VIEW-AS TEXT
          SIZE 13.13 BY 1 AT ROW 2.5 COL 28
     "Код МЦ" VIEW-AS TEXT
          SIZE 7.88 BY 1 AT ROW 1.13 COL 28.13
     "Ед. изм.:" VIEW-AS TEXT
          SIZE 10.63 BY 1 AT ROW 6.71 COL 15.5
     SPACE(50.49) SKIP(4.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Номинал материальной ценности"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_wealth B "?" ? ub wealth
      TABLE: locked_wth-par B "?" ? ub wth-par
      TABLE: tt-wth-par T "?" NO-UNDO ub wth-par
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

ASSIGN
       B-unit:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       Bpar-feat:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN locked_wth-par.par-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-par.par-feat IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-par.par-rate IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-par.par-unit IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE EXP-LABEL                                       */
ASSIGN
       tt-wth-par.par-unit:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-wth-par.par-val IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR SELECTION-LIST Spar-feat IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       Spar-feat:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR SELECTION-LIST Spar-unit IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       Spar-unit:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-wth-par.wth-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Номинал материальной ценности */
DO:
  run proc-save in this-procedure no-error .
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Номинал материальной ценности */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
    define variable v-rid-list  as   character            no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .


  run ref/cwthhist.w (
                   input parparentproc
                 , input ?   /* p-curr-host-code */
                 , input '':U    /* p-curr-obj-type  */
                 , input 0    /* p-curr-obj-code  */
                 , input "":U          /* bttns */
                 , input "subject":U       /* p-mode */
                 , input tt-wth-par.wth-code /*p-wth-code*/
                 , INPUT tt-wth-par.par-code  /*p-par-code*/
                 , input ?             /* p-host-code */
                 , input ?             /* p-obj-type*/
                 , input ?             /* p-obj-code*/
                 , input ?             /* p-corr-user-db-num */
                 , input "":U          /* p-corr-user-name */
                 , input {&table_wth-par}  /* p-subject */
                 , input v-cntxt-db-num      /* p-db-num */
                 , input ?
                 , input ?
                 , input-output v-rid-list
                 ) no-error.
if error-status:error then do:
  message return-value skip
          error-status:get-message(1)
  view-as alert-box.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-unit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-unit Dialog-Frame
ON CHOOSE OF B-unit IN FRAME Dialog-Frame
DO:
run ch-units IN THIS-PROCEDURE .
apply "entry" to tt-wth-par.par-unit in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Bpar-feat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Bpar-feat Dialog-Frame
ON CHOOSE OF Bpar-feat IN FRAME Dialog-Frame
DO:
  VIEW
  spar-feat
  in frame {&frame-name}.
  ENABLE
  spar-feat
  with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-par.par-unit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-par.par-unit Dialog-Frame
ON LEAVE OF tt-wth-par.par-unit IN FRAME Dialog-Frame /* par-unit */
DO:
    if locked_wealth.is-money then do:
        if input frame {&frame-name} tt-wth-par.par-UNIT <> buf_currency.curr-abbr AND
           input frame {&frame-name} tt-wth-par.par-UNIT <> buf_currency.part-abbr then do:
           message "Выберите сокр. название валюты или ее дробной части"
           view-as alert-box.
        end.
    end.
    else do:
        if not can-FIND( ub.units where ub.units.unit-name = input frame {&frame-name} tt-wth-par.par-UNIT )
           then do:
           tt-wth-par.par-unit = "?".
           DISPLAY tt-wth-par.par-unit
           WITH FRAME {&Frame-name}.
           run ch-units IN this-procedure.
        end.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Spar-feat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Spar-feat Dialog-Frame
ON LEAVE OF Spar-feat IN FRAME Dialog-Frame
DO:
    display
  spar-feat:screen-value @ tt-wth-par.par-feat
  with frame {&frame-name}.
  hide spar-feat
  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Spar-feat Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF Spar-feat IN FRAME Dialog-Frame
DO:
   display
  spar-feat:screen-value @ tt-wth-par.par-feat
  with frame {&frame-name}.
  hide spar-feat
  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Spar-feat Dialog-Frame
ON RETURN OF Spar-feat IN FRAME Dialog-Frame
DO:
  display
  spar-feat:screen-value @ tt-wth-par.par-feat
  with frame {&frame-name}.
  hide spar-feat
  in frame {&frame-name}.
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF lookup(par-mode, {&add-def} + {&comma-char} +
                      {&UPDATE} + {&comma-char} +
                      {&LOOKUP}) = 0 THEN DO:
  message
    "Неверное значение параметра par-mode" par-mode
    VIEW-AS ALERT-BOX ERROR.
    UNDO main-block, RETURN ERROR.
  END.

  IF pwth-code = 0  THEN DO:
      run ref/wth-ref.w (
                         input parparentproc
                        ,input "b-sel"
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input {&all}
                        ,input-output v-rid-list) no-error.
      if v-rid-list = "" then return error.
      find first locked_wealth exclusive-LOCK WHERE
              recid(locked_wealth) = integer(entry(1, v-rid-list)) NO-ERROR.
  END.
  ELSE do:
    FIND FIRST LOCKED_wealth EXCLUSIVE-LOCK WHERE
             LOCKED_wealth.wth-code = pwth-code NO-ERROR.
    IF NOT AVAILABLE LOCKED_wealth THEN DO:
        message vss-workfile vss-revision vss-description skip
        "Не найдена материальная ценность с кодом " pwth-code
        view-as alert-box error.
        return error.
    END.
  END.
  IF par-mode = {&add-def} THEN DO:
    CREATE tt-wth-par.
    assign
    tt-wth-par.wth-code = LOCKED_wealth.wth-code
    .

  END.
  ELSE DO:
     IF par-mode = {&LOOKUP} THEN DO:
       FIND FIRST LOCKED_wth-par NO-LOCK WHERE
                LOCKED_wth-par.wth-code = pwth-code
           AND  LOCKED_wth-par.par-code = ppar-code NO-ERROR.
     END.
     ELSE DO:
         FIND FIRST LOCKED_wth-par exclusive-LOCK WHERE
                  LOCKED_wth-par.wth-code = pwth-code
             AND  LOCKED_wth-par.par-code = ppar-code NO-ERROR.

     END.
     IF NOT AVAILABLE LOCKED_wth-par THEN DO:
        MESSAGE
        SUBSTITUTE("Не найден номинал с кодом &1 для МЦ с  кодом &2", ppar-code, pwth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.
    p-rec = recid(Locked_wth-par).
    CREATE tt-wth-par.
    BUFFER-COPY LOCKED_wth-par TO tt-wth-par.
  END.
  { gbl/getcntxt.i get }
  run Myenable IN THIS-PROCEDURE NO-ERROR.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ch-units Dialog-Frame
PROCEDURE ch-units :
define variable ref-rec as recid no-undo .
run ref/units.w ( input parparentproc
                ,input yes
                ,output ref-rec ).
if ref-rec = ? then do:
  apply "entry" to b-unit in frame {&frame-name}.
  return no-apply.
end.
FIND buf_units WHERE recid (buf_units) = ref-rec NO-LOCK.
DISPLAY
buf_units.unit-name @ tt-wth-par.par-UNIT
with frame {&frame-name}.
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
  IF AVAILABLE locked_wth-par THEN
    DISPLAY locked_wth-par.par-code
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-par THEN
    DISPLAY tt-wth-par.par-val tt-wth-par.par-rate tt-wth-par.par-feat
          tt-wth-par.wth-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help tt-wth-par.par-val tt-wth-par.par-rate
         B-unit tt-wth-par.par-feat Bpar-feat tt-wth-par.wth-code
         locked_wth-par.par-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-rid-list as char no-undo.
if locked_wealth.curr-code <> ? then do:
    FIND FIRST buf_currency No-LOCK WHERE
                buf_currency.curr-code = locked_wealth.curr-code NO-ERROR.
    if not avail buf_currency then do:
       message vss-workfile vss-revision vss-description skip
       SUBSTITUTE("Не найдена валюта с кодом &1" +
                   "для материальной ценности с кодом &1"
                  ,locked_wealth.curr-code
                  ,locked_wealth.wth-code)
        view-as alert-box error.
        return error.
    end.
end.
else if not locked_wealth.is-ser = 1 then do:
    FIND FIRST buf_units No-LOCK WHERE
                buf_units.unit-name = locked_wealth.unit-base NO-ERROR.
    if not avail buf_units then do:
       message vss-workfile vss-revision vss-description skip
       substitute("Не найдена единица измерения &1" +
                  "для материальной ценности с кодом &1"
                  ,locked_wealth.unit-base
                  ,locked_wealth.wth-code)
        view-as alert-box error.
        return error.
    end.
end.
ENABLE
B-exit WHEN par-mode <> {&LOOKUP}
b-quit
B-Help
tt-wth-par.par-val when (par-mode = {&add-def} or par-mode = {&update})
tt-wth-par.par-rate when ((par-mode = {&add-def} or par-mode = {&update}) and locked_wealth.is-ser = 0 )
tt-wth-par.par-feat when (par-mode = {&add-def} or par-mode = {&update})
b-hist WHEN par-mode <> {&add-def}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if locked_wealth.is-money = yes then do:
    spar-unit:list-items = buf_currency.curr-abbr + {&comma-char} + buf_currency.part-abbr.
    view spar-unit
    in frame {&frame-name}.
    ENABLE
    spar-unit when (par-mode = {&add-def}  OR par-mode = {&update})
/*        spar-feat when (par-mode = {&add-def}  OR par-mode = {&update})*/
    bpar-feat when (par-mode = {&add-def}  OR par-mode = {&update})
    with frame {&frame-name}.
end.
else do:
    view
    b-unit
    tt-wth-par.par-unit
    in frame {&frame-name}.
    ENABLE
    b-unit when ((par-mode = {&add-def} or par-mode = {&update}) and locked_wealth.is-ser = 0 )
    tt-wth-par.par-unit when ((par-mode = {&add-def} or par-mode = {&update}) and locked_wealth.is-ser = 0 )
    with frame {&frame-name}.
end.
if par-mode = {&update} or par-mode = {&lookup} then do:
    DISPLAY
    tt-wth-par.wth-code
    locked_wth-par.par-code
    tt-wth-par.par-feat
    tt-wth-par.par-rate
    tt-wth-par.par-val
    WITH FRAME {&frame-name}  .
    if locked_wealth.is-money = yes then do:
        assign
        spar-unit:screen-value = tt-wth-par.par-unit no-error.
    end.
    else do:
        display
        tt-wth-par.par-unit
        WITH FRAME {&frame-name}  .
    end.
end.
if par-mode = {&add-def} then do with frame {&frame-name} :
    DISPLAY
    tt-wth-par.wth-code
    .
    if NOT locked_wealth.is-money then
    DISPLAY
    locked_wealth.unit-base @ tt-wth-par.par-unit
    .
    if locked_wealth.is-ser = 1 then do:
       tt-wth-par.par-rate:screen-value = '1'.
       for first buf_wth-gds no-lock where buf_wth-gds.wth-code = locked_wealth.wth-code,
           first buf_goods   no-lock where buf_goods.gds-code = buf_wth-gds.gds-code:
           display buf_goods.unit-base @ tt-wth-par.par-unit with frame {&frame-name}.
           disable  tt-wth-par.par-unit
                    b-unit
           with frame {&frame-name}.
       end.
    end.
end.
IF par-mode = {&LOOKUP} THEN DO:
  HIDE
  b-exit IN FRAME {&FRAME-NAME}
  .
  ASSIGN
  b-quit:COLUMN = 1
  b-quit:LABEL = "&Выход".
END.
frame {&frame-name}:title = substitute("&1 &2 &3"
                                     ,frame {&frame-name}:title
                                     ,locked_wealth.wth-name
                                     ,par-mode).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
IF par-mode = {&LOOKUP} THEN UNDO, RETURN ERROR.
assign
FRAME {&frame-name}
tt-wth-par.par-feat
tt-wth-par.par-rate
tt-wth-par.par-unit
tt-wth-par.par-val
Spar-feat
Spar-unit
.
if par-mode = {&update} then v-rec = p-rec.
run ref/wth-par1.p ( INPUT par-mode
                    ,INPUT NO /*p-silent*/
                    ,INPUT-OUTPUT v-rec
                    ,INPUT tt-wth-par.wth-code
                    ,INPUT tt-wth-par.par-code
                    ,INPUT tt-wth-par.par-val
                    ,INPUT tt-wth-par.par-feat
                    ,INPUT tt-wth-par.par-rate
                    ,INPUT (IF tt-wth-par.par-unit:VISIBLE IN FRAME {&FRAME-NAME}
                            THEN tt-wth-par.par-unit
                            ELSE spar-unit)
                     ) NO-ERROR.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
