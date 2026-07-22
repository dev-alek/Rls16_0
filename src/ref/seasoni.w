&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Корректировка сезона

Автор: Чернова Светлана Александровна
Дата создания: 03/19/02
Author: Svetlana Chernova
Creation date: 03/19/02

*/

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-def          as character no-undo.
define input-output parameter  rr      as recid no-undo.

define shared variable g#db-num as integer   no-undo . 

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Корректировка сезона" .

{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define buffer buf_season for ub.season .
define buffer season-1 for ub.season .
define buffer buf_season-attr for ub.season-attr .
define variable loc-month-1 as integer no-undo.
define variable loc-month-2 as integer no-undo.
define variable v-user-select as logical no-undo .
define variable v-sel-obj-type like ub.clients.obj-type no-undo .
define variable v-sel-obj-code like ub.clients.obj-code no-undo .

{ gbl/getcntxt.i get }
{ ref/chgdssea.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no
&scop sel-obj ~
  ~{                       ~
   gbl/uobjsone.i         ~
    parparentproc         ~
    v-cntxt-db-num        ~
    v-cntxt-userid        ~
    v-cntxt-host-code-obj ~
    v-cntxt-obj-type      ~
    v-cntxt-obj-code      ~
    v-user-select         ~
    v-sel-obj-type        ~
    v-sel-obj-code        ~
  ~}  

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-OK B-Cancel B-Help loc-name loc-month-1 ~
loc-month-2 loc-code
&Scoped-Define DISPLAYED-OBJECTS loc-name loc-month-1 loc-month-2 loc-code

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE loc-month-1-date AS date FORMAT "99/99/99":U 
     LABEL "c"
     view-as fill-in
     SIZE 9.00 BY 1 NO-UNDO.

DEFINE VARIABLE loc-month-2-date AS date FORMAT "99/99/99":U 
     LABEL "по"
     view-as fill-in
     SIZE 9.00 BY 1 NO-UNDO.

DEFINE VARIABLE loc-code AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "Код"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE loc-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 47.13 BY 1 NO-UNDO.

DEFINE VARIABLE rs-area AS CHARACTER INIT {&sea-global}
     LABEL "Сезон"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "глобальный", {&sea-global},
          "локальный", {&sea-local}
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE obj-name AS character 
     LABEL "Объект"
     VIEW-AS TEXT 
     SIZE 7.50 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Объект"
     SIZE 3 BY 1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 21
     rs-area AT ROW 2.25 COL 6.25
     loc-name AT ROW 4.5 COL 11.25 COLON-ALIGNED
     loc-month-1-date AT ROW 6 COL 11 COLON-ALIGNED
     loc-month-2-date AT ROW 6 COL 25 COLON-ALIGNED
     loc-code AT ROW 3.5 COL 11.25 COLON-ALIGNED
     obj-name AT ROW 7.5 COL 5.0
     b-obj AT ROW 7.35 COL 20.25
     SPACE(40.00) SKIP(1.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Сезон"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel.


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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Сезон */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-OK Dialog-Frame
ON CHOOSE OF B-OK IN FRAME Dialog-Frame /* Ввод */
DO:
  
  define variable v-ok as logical no-undo.
  define variable v-sea-code as integer no-undo.
  define variable v-db-num as integer no-undo.
  define variable v-longchar as longchar no-undo .
  
  define buffer buf_goods for ub.goods.
  define buffer buf_gds-season for ub.gds-season.
  
  Assign frame {&frame-name}
    loc-code loc-month-1-date loc-month-2-date loc-name.
  assign
    loc-month-1 = integer(loc-month-1-date)
    loc-month-2 = integer(loc-month-2-date)
    .
  if loc-month-1 > loc-month-2 Then 
  do:
    message "В интервале дат первая должна быть меньше второй ! " view-as  alert-box  error.
    apply "entry"  to loc-month-1-date .
      return no-apply.
     end.

  if loc-month-1 = ? or loc-month-2 = ? Then 
  do:
    message "Значение дат не может быть пустым " view-as  alert-box  error.
    apply "entry"  to loc-month-1-date .
      return no-apply.
      end.

  if loc-name = "" then 
  do:
    message "Введите название сезона ! " view-as  alert-box  error.
    apply "entry"  to loc-name .
      return no-apply.
      end.

  if obj-name = "" and rs-area = {&sea-local} then 
  do:
    message "Укажите объект локального сезона ! " view-as  alert-box  error.
    apply "entry"  to loc-name .
    return no-apply.
  end.
  
  

  for each buf_gds-season no-lock where buf_gds-season.sea-code = buf_season.sea-code
    and buf_gds-season.db-num = buf_season.db-num:
    run chk-gdssea in this-procedure 
      ( input buf_gds-season.gds-code,
        input obj-name,
        input buf_season.sea-month-1,
        input buf_season.sea-month-2,
        input rowid (buf_season),
        output v-sea-code,
        output v-db-num,
        output v-ok) no-error.
    if not v-ok then do:
      find first buf_goods no-lock where buf_goods.gds-code = buf_gds-season.gds-code no-error.
      assign
        v-longchar = v-longchar +
          substitute ("Товар &1 &2 пересекается с сезоном &3 &4.&5", buf_goods.gds-code, buf_goods.gds-name, v-sea-code, buf_season.sea-name, {&new-line})
        .
      run gbl/d-longchar.w (
              ?,
              'Editor_row=2\':u
            + 'title=Проверка товарного наполнения сезона: при изменении сезона возникли пересечения\':u
            + 'Editor_col=1\':u
            + 'Editor_width=96\':u
            + 'Editor_height=21\':u
            + 'readonly=yes\':u
          ,input-output v-longchar
          ,output v-ok ) no-error .
          if error-status :error then message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "4"
            view-as alert-box error
          .
      assign
        v-longchar = "".
      return no-apply.
      end.
    end.

  if p-def = {&add-def} then 
  do:
    create buf_season.
    Assign
      buf_season.sea-code = loc-code
      buf_season.db-num   = v-cntxt-db-num
      .
      end.

  find first buf_season-attr exclusive-lock where buf_season-attr.sea-code = buf_season.sea-code and buf_season-attr.attr-code = {&seaattr-obj} no-error.
  if rs-area = {&sea-global} then do:
    if available buf_season-attr then do:
      delete buf_season-attr.
    end.
  end.
  else do: 
    if not available buf_season-attr then do:
      create buf_season-attr.
      assign
        buf_season-attr.db-num = v-cntxt-db-num
      .
    end.
       Assign
      buf_season-attr.sea-code = buf_season.sea-code
      buf_season-attr.attr-code = {&seaattr-obj}
      buf_season-attr.attr-value = obj-name
         .
    end.

  if p-def = {&add-def} OR p-def = {&update}  then do:
       Assign
      buf_season.sea-name    = loc-name
      buf_season.sea-month-1 = integer(loc-month-1-date)
      buf_season.sea-month-2 = integer(loc-month-2-date)
      rr                 = recid(buf_season)
        .
  end.   
    else rr = ? .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-obj Dialog-Frame
ON CHOOSE OF B-obj IN FRAME Dialog-Frame  /* Объект */
DO:
  {&sel-obj}
  obj-name:screen-value in frame Dialog-Frame = if v-sel-obj-code <> 0 then string (v-sel-obj-type) + string (v-sel-obj-code) else "".
  assign
    obj-name.
/*  apply "entry" . */
/*  return no-apply.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME rs-area
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-area Dialog-Frame
ON VALUE-CHANGED OF rs-area IN FRAME Dialog-Frame /* Добавить */
DO:
  assign rs-area.
  if rs-area = {&sea-global} then do:
    DISABLE
      B-obj with frame Dialog-Frame.
    obj-name = "".
    DISPLAY obj-name with frame Dialog-Frame.  
  end.
  else do:
    ENABLE
      B-obj with frame Dialog-Frame.
    obj-name = "".
    DISPLAY obj-name with frame Dialog-Frame. 
  end.
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

assign frame {&frame-name}:title = "Сезон - " + p-def.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  
  run enable_UI in this-procedure .
  run local-init in this-procedure  no-error .
      if error-status :error then return error.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

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
  DISPLAY loc-name loc-month-1-date loc-month-2-date loc-code b-obj obj-name rs-area
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-Help loc-name loc-month-1-date loc-month-2-date loc-code b-obj obj-name rs-area 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-init Dialog-Frame
PROCEDURE local-init :
if Lookup(p-def, {&add-def} + "," + {&Lookup} + "," +  {&update})  = 0 then return error.

  if p-def = {&update} then 
  do:
    find first buf_season where recid(buf_season) = rr  exclusive-lock  no-error .
      if error-status :error then return error.
    find first buf_season-attr exclusive-lock where buf_season-attr.sea-code = buf_season.sea-code and buf_season-attr.attr-code = {&seaattr-obj} no-error.
    DISABLE
      B-obj obj-name rs-area with frame Dialog-Frame.
    if available buf_season-attr then do:
      rs-area = {&sea-local}.
      obj-name:screen-value in frame Dialog-Frame = buf_season-attr.attr-value.
      assign
        obj-name.
  end.
    else do:
      rs-area = {&sea-global}.
      if g#db-num <> 0 then disable b-ok with frame Dialog-Frame.
    end.
  end.
  if p-def = {&lookup} then 
  do:
    find first buf_season where recid(buf_season) = rr  no-lock  no-error .
      if error-status :error then return error.
  end.

  if available buf_season then 
  do:
        assign
      loc-code         = buf_season.sea-code
      loc-name         = buf_season.sea-name
      loc-month-1      = buf_season.sea-month-1
      loc-month-2      = buf_season.sea-month-2
      loc-month-1-date = date (buf_season.sea-month-1)
      loc-month-2-date = date (buf_season.sea-month-2)
          .
    end.
  else 
  do:
    if p-def = {&add-def} then 
    do:
      assign
        loc-code = next-value ( s-casm , {&db-name_schema} )
        loc-code:screen-value in frame Dialog-Frame = string(loc-code) 
      .
      disable b-obj with frame Dialog-Frame.
      if g#db-num <> 0 then do:
        rs-area = {&sea-local}.
        display rs-area with frame Dialog-Frame.
        disable rs-area with frame Dialog-Frame.
        enable b-obj with frame Dialog-Frame.
      end.
        end.
    end.
  DISPLAY loc-name loc-month-1-date loc-month-2-date loc-code rs-area
      WITH FRAME Dialog-Frame.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
