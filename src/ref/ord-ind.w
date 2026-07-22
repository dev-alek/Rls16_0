&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE TEMP-TABLE tt-gds-obj-prop NO-UNDO LIKE ub.gds-obj-prop.
DEFINE TEMP-TABLE tt-gds-obj-prop-attr NO-UNDO LIKE ub.gds-obj-prop-attr.
DEFINE TEMP-TABLE tt0-gds-obj-prop NO-UNDO LIKE ub.gds-obj-prop.
DEFINE TEMP-TABLE tt0-gds-obj-prop-attr NO-UNDO LIKE ub.gds-obj-prop-attr.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования параметров заказа

Автор: Чернова Светлана Александровна
Дата создания: 03/03/05
Author: Svetlana Chernova
Creation date: 03/03/05

*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo.
define input parameter p-gds-code as integer no-undo.
define input parameter p-host-code like ub.clients.obj-code no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-update-instantly as logical no-undo .
define output parameter p-updated AS LOGICAL no-undo.
DEFINE INPUT-OUTPUT PARAMETER TABLE  FOR tt0-gds-obj-prop.
DEFINE INPUT-OUTPUT PARAMETER TABLE  FOR tt0-gds-obj-prop-attr.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования параметров заказа".
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ ref/gds-ind1.i gds-obj-prop-attr }
{ ref/gdsoattr.i }
define variable v-ii as integer no-undo .
define variable jj as integer no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-gds-obj-prop buf_goods

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define SELF-NAME Dialog-Frame
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-gds-obj-prop NO-LOCK, ~
             EACH buf_goods OF tt-gds-obj-prop NO-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY {&SELF-NAME} FOR EACH tt-gds-obj-prop NO-LOCK, ~
             EACH buf_goods OF tt-gds-obj-prop NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-gds-obj-prop buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-gds-obj-prop
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame buf_goods


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS buf_goods.artic buf_goods.prod-type ~
buf_goods.prod-code buf_goods.gds-code buf_goods.gds-name ~
tt-gds-obj-prop.grop-date-update tt-gds-obj-prop.grop-who-update ~
tt-gds-obj-prop.grop-db-num-update
&Scoped-define ENABLED-TABLES buf_goods tt-gds-obj-prop
&Scoped-define FIRST-ENABLED-TABLE buf_goods
&Scoped-define SECOND-ENABLED-TABLE tt-gds-obj-prop
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help F-time
&Scoped-Define DISPLAYED-FIELDS tt-gds-obj-prop.gdop-min-stock ~
tt-gds-obj-prop.grop-max-stock tt-gds-obj-prop.grop-min-order ~
tt-gds-obj-prop.grop-level-always-presence buf_goods.artic ~
buf_goods.prod-type buf_goods.prod-code buf_goods.gds-code ~
buf_goods.gds-name tt-gds-obj-prop.grop-date-update ~
tt-gds-obj-prop.grop-who-update tt-gds-obj-prop.grop-db-num-update
&Scoped-define DISPLAYED-TABLES tt-gds-obj-prop buf_goods
&Scoped-define FIRST-DISPLAYED-TABLE tt-gds-obj-prop
&Scoped-define SECOND-DISPLAYED-TABLE buf_goods
&Scoped-Define DISPLAYED-OBJECTS F-time

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
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Hist
     LABEL "Ис&тория"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE F-time AS CHARACTER FORMAT "X(5)":U
     LABEL "Время изменения"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-gds-obj-prop,
      buf_goods SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 78.5
     B-Help AT ROW 1 COL 88.5
     tt-gds-obj-prop.gdop-min-stock AT ROW 5.77 COL 35.5 COLON-ALIGNED FORMAT "->>>,>>9.999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-gds-obj-prop.grop-max-stock AT ROW 6.77 COL 35.5 COLON-ALIGNED FORMAT "->>>,>>9.999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-gds-obj-prop.grop-min-order AT ROW 7.77 COL 35.5 COLON-ALIGNED FORMAT "->>>,>>9.999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-gds-obj-prop.grop-level-always-presence AT ROW 8.77 COL 35.5 COLON-ALIGNED FORMAT ">.9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     buf_goods.artic AT ROW 2.77 COL 24 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 17 BY .67
     buf_goods.prod-type AT ROW 2.77 COL 41.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
     buf_goods.prod-code AT ROW 2.77 COL 46 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10 BY .67
     buf_goods.gds-code AT ROW 3.5 COL 24 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 10 BY .67
     buf_goods.gds-name AT ROW 4.5 COL 24 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 71.5 BY 1
          BGCOLOR 3 FGCOLOR 15
     tt-gds-obj-prop.grop-date-update AT ROW 11.27 COL 75.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 9 BY .67
     F-time AT ROW 12.27 COL 75.5 COLON-ALIGNED
     tt-gds-obj-prop.grop-who-update AT ROW 13.27 COL 75.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 19.5 BY .67
     tt-gds-obj-prop.grop-db-num-update AT ROW 14.27 COL 75.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 5 BY .67
     SPACE(16.00) SKIP(0.55)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты товара на объекте для заказов".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_goods B "?" ? ub goods
      TABLE: tt-gds-obj-prop T "?" NO-UNDO ub gds-obj-prop
      TABLE: tt-gds-obj-prop-attr T "?" NO-UNDO ub gds-obj-prop-attr
      TABLE: tt0-gds-obj-prop T "?" NO-UNDO ub gds-obj-prop
      TABLE: tt0-gds-obj-prop-attr T "?" NO-UNDO ub gds-obj-prop-attr
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

/* SETTINGS FOR BUTTON B-Hist IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-gds-obj-prop.gdop-min-stock IN FRAME Dialog-Frame
   NO-ENABLE EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-gds-obj-prop.grop-level-always-presence IN FRAME Dialog-Frame
   NO-ENABLE EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-gds-obj-prop.grop-max-stock IN FRAME Dialog-Frame
   NO-ENABLE EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-gds-obj-prop.grop-min-order IN FRAME Dialog-Frame
   NO-ENABLE EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-gds-obj-prop NO-LOCK,
      EACH buf_goods OF tt-gds-obj-prop NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Атрибуты товара на объекте для заказов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:

  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Hist Dialog-Frame
ON CHOOSE OF B-Hist IN FRAME Dialog-Frame /* История */
DO:
define variable pp-rid-list as character no-undo .

 run ref/cgds-ind.w (
  input  parparentproc ,
  input  tt-gds-obj-prop.gds-code ,
  input  tt-gds-obj-prop.obj-type ,
  input  tt-gds-obj-prop.obj-code ,
  input-output pp-rid-list    ).

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
  run init-proc no-error .
  if error-status :error then return error return-value .

  define variable v-user-name as character no-undo .
  run enable_ui.
  if available tt-gds-obj-prop then do:
  { gbl/usrfulnm.i
    tt-gds-obj-prop.grop-who-update
    v-user-name }
  end.
  display v-user-name @ tt-gds-obj-prop.grop-who-update with frame {&frame-name} .

  if p-mode = {&lookup} then do:
      assign
        b-quit:label = "&Выход"
        b-quit:col = 1
      .
      hide b-exit in frame {&frame-name}.
  end.
find first tt-gds-obj-prop no-error .
DISPLAY string(tt-gds-obj-prop.grop-time-update,"hh:mm") @ f-time WITH FRAME {&frame-name}.

enable
b-exit when p-mode <> {&lookup}
b-quit
b-hist when p-mode = {&lookup}
b-help
tt-gds-obj-prop.gdop-min-stock               when p-mode <> {&lookup}
tt-gds-obj-prop.grop-level-always-presence   when p-mode <> {&lookup}
tt-gds-obj-prop.grop-max-stock               when p-mode <> {&lookup}
tt-gds-obj-prop.grop-min-order               when p-mode <> {&lookup}
with frame dialog-frame.

if p-obj-type = {&cmp}  then do:
   hide
   tt-gds-obj-prop.grop-max-stock
   in frame {&frame-name} .
end.

view frame dialog-frame.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS tt-gds-obj-prop.gdop-min-stock.
END.
run disable_ui.

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
  DISPLAY F-time
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_goods THEN
    DISPLAY buf_goods.artic buf_goods.prod-type buf_goods.prod-code
          buf_goods.gds-code buf_goods.gds-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-gds-obj-prop THEN
    DISPLAY tt-gds-obj-prop.gdop-min-stock tt-gds-obj-prop.grop-max-stock
          tt-gds-obj-prop.grop-min-order
          tt-gds-obj-prop.grop-level-always-presence
          tt-gds-obj-prop.grop-date-update tt-gds-obj-prop.grop-who-update
          tt-gds-obj-prop.grop-db-num-update
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help buf_goods.artic buf_goods.prod-type
         buf_goods.prod-code buf_goods.gds-code buf_goods.gds-name
         tt-gds-obj-prop.grop-date-update F-time
         tt-gds-obj-prop.grop-who-update tt-gds-obj-prop.grop-db-num-update
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
  if p-obj-type = {&cmp}  then do:
     assign
       frame {&frame-name}:title = "Атрибуты товара для ЗАКАЗА на фирме "  + string(p-obj-code)
     .
  end.
  else frame {&frame-name}:title = "Атрибуты товара для ЗАКАЗА на объекте " + string(p-obj-type)  + string(p-obj-code) .


if p-mode = {&lookup} then
   find first tt0-gds-obj-prop no-lock where
              tt0-gds-obj-prop.gds-code =  p-gds-code and
              tt0-gds-obj-prop.obj-type =  p-obj-type and
              tt0-gds-obj-prop.obj-code =  p-obj-code no-error .
else
   find first tt0-gds-obj-prop exclusive-lock  where
              tt0-gds-obj-prop.gds-code =  p-gds-code and
              tt0-gds-obj-prop.obj-type =  p-obj-type and
              tt0-gds-obj-prop.obj-code =  p-obj-code no-error .

 for each tt-gds-obj-prop :
   delete tt-gds-obj-prop.
 end.
 for each tt-gds-obj-prop-attr :
   delete tt-gds-obj-prop-attr.
 end.
  CREATE tt-gds-obj-prop.
  if available tt0-gds-obj-prop then
     BUFFER-COPY tt0-gds-obj-prop TO tt-gds-obj-prop .
  else do:
    run cur-time in this-procedure(output v-date, output v-time).
    if p-gds-code = 0 then p-gds-code = -1.
    assign
    tt-gds-obj-prop.gdop-assort-min    = no
    tt-gds-obj-prop.gdop-igt           = {&ass-izd-empty}
    tt-gds-obj-prop.gds-code           = p-gds-code
    tt-gds-obj-prop.grop-date-update   = v-date
    tt-gds-obj-prop.grop-time-update   = v-time
    tt-gds-obj-prop.grop-db-num-update = g#db-num
    tt-gds-obj-prop.grop-who-update    = g#userid
    tt-gds-obj-prop.obj-code           = p-obj-code
    tt-gds-obj-prop.obj-type           = p-obj-type
    .
  end.
  for each tt0-gds-obj-prop-attr :
    create tt-gds-obj-prop-attr.
    buffer-copy tt0-gds-obj-prop-attr
    to tt-gds-obj-prop-attr.
  end.
  if p-obj-type = {&shop}
  or p-obj-type = {&stock} then do:
    /*атрибутов работающих на фирму - у нас нет пока!!!!*/
    do v-ii = 1 to num-entries({&gdspoatr-list-obj}):
      if lookup(entry(v-ii, {&gdspoatr-list-obj}), {&gdspoatr-list-spec}) = 0 then do:
      find first tt-gds-obj-prop-attr where
               tt-gds-obj-prop-attr.obj-type = p-obj-type
           and tt-gds-obj-prop-attr.obj-code = p-obj-code
           and tt-gds-obj-prop-attr.attr-code = entry(v-ii, {&gdspoatr-list-obj}) no-error.
      if not available tt-gds-obj-prop-attr then do:
        create tt-gds-obj-prop-attr.
        assign
        tt-gds-obj-prop-attr.obj-type = p-obj-type
        tt-gds-obj-prop-attr.obj-code = p-obj-code
        tt-gds-obj-prop-attr.attr-code = entry(v-ii, {&gdspoatr-list-obj})
        .
         /*получим начальное значение*/
        define variable v-format         as character no-undo .
        define variable v-label          as character no-undo .
        define variable v-user-can-edit  as logical   no-undo .
        define variable v-output-display as logical   no-undo .
        define variable v-other          as character no-undo .
        define variable v-type           as character no-undo .

        run gdspoatr-name in this-procedure
          (input  entry(v-ii, {&gdspoatr-list-obj})           /* p-code           */
          ,output v-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
        if error-status :error then do:
          undo, return error return-value .
        end.
        do jj = 1 to num-entries(v-other, {&slash-char}):
          if entry(1, entry(jj, v-other, {&slash-char}), "=":U) = "init-value":U then do:
            assign
            tt-gds-obj-prop-attr.attr-value = string(entry(2, entry(jj, v-other, {&slash-char}), "=":U))
            .
          end.
        end. /*jj*/
      end. /*if not available tt-gds-obj-prop-attr then do:*/
      release tt-gds-obj-prop-attr.
      end. /*if lookup(entry(v-ii, {&gdspoatr-list-obj}), {&gdspoatr-list-spec}) = 0 then do:*/
    end. /*do v-ii = 1 to num-entries({&gdspoatr-list-obj}):*/

  end. /*if p-obj-type = {&shop}*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign frame {&frame-name}  tt-gds-obj-prop.gdop-min-stock .
assign frame {&frame-name}  tt-gds-obj-prop.grop-level-always-presence .
assign frame {&frame-name}  tt-gds-obj-prop.grop-max-stock  .
assign frame {&frame-name}  tt-gds-obj-prop.grop-min-order .
define variable p-recid as recid no-undo.
define variable v-ident as logical no-undo .

if p-update-instantly then do:
    run gds-ind1
        (input-output p-recid
        ,tt-gds-obj-prop.gds-code
        ,tt-gds-obj-prop.obj-type
        ,tt-gds-obj-prop.obj-code
        ,tt-gds-obj-prop.gdop-igt
        ,tt-gds-obj-prop.gdop-assort-min
        ,tt-gds-obj-prop.gdop-min-stock
        ,tt-gds-obj-prop.grop-level-always-presence
        ,tt-gds-obj-prop.grop-max-stock
        ,tt-gds-obj-prop.grop-min-order
        ,input table tt-gds-obj-prop-attr
        ) no-error .
    if error-status :error then  do:
       message error-status :get-message(1) skip return-value .
       return error return-value .
    end.
END.
ELSE DO:
   if not available tt0-gds-obj-prop then
   create tt0-gds-obj-prop.
    if p-mode = {&add-def} then do:
      p-updated = yes.
    end.
    else do:
      if available tt0-gds-obj-prop then do:
        buffer-compare tt0-gds-obj-prop
        to
        tt-gds-obj-prop save result in v-ident.
        assign
        p-updated = not v-ident.
      end.
      else do:
        if available tt-gds-obj-prop then p-updated = yes.
      end.
    end.
   buffer-copy tt-gds-obj-prop
   except gds-code
   to tt0-gds-obj-prop
   .
   if p-obj-type = {&shop}
   or p-obj-type = {&stock} then do:
     for each tt-gds-obj-prop-attr:
       find first tt0-gds-obj-prop-attr where
                  tt0-gds-obj-prop-attr.obj-type = p-obj-type
              and tt0-gds-obj-prop-attr.obj-code = p-obj-code
              and tt0-gds-obj-prop-attr.attr-code = tt-gds-obj-prop-attr.attr-code no-error .
       if not available tt0-gds-obj-prop-attr then do:
         create tt0-gds-obj-prop-attr.
         p-updated = yes.
       end.
        buffer-compare tt0-gds-obj-prop-attr
        to
        tt-gds-obj-prop-attr save result in v-ident.
        assign
        p-updated = (p-updated or not v-ident).
       buffer-copy tt-gds-obj-prop-attr
       except gds-code
       to
       tt0-gds-obj-prop-attr .
     end.
   end.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME