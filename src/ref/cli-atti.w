&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE Temp-hattr NO-UNDO LIKE ub.clients-attr
       field user-can-edit as logical
       field output-display as logical
       field value_ as character
       field code as char
       INDEX attrc is
       UNIQUE PRIMARY
       obj-type
       obj-code
       code
       INDEX attrcl is UNIQUE
       attr-code
       obj-type
       obj-code
       index ioutput
       output-display.
DEFINE TEMP-TABLE tt0-clients-attr NO-UNDO LIKE ub.clients-attr.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Атрибуты клиента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as char no-undo.
define input parameter p-obj-type as char no-undo.
define input parameter p-obj-code as int no-undo.
define input parameter p-update-instantly as logical no-undo .
define output parameter p-updated AS LOGICAL no-undo.
define INPUT-OUTPUT parameter table for tt0-clients-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Атрибуты клиента ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/clntattr.i interface parparentproc }
{ ref/attr-pop.i def }
{ ref/attr-pop.i proc }

define variable updated as logical no-undo.
define variable add-option as char no-undo.
define variable temp-doc-rec as recid no-undo.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.

DEFINE MENU MENU-b-ins .

&scoped-define  cliattr-type-get-error message "Ошибка при определении названия и типа атрибута клиента!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  cliattr-value-get-error message "Ошибка при определении значения атрибута клиента!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

&scoped-define  cliattr-write-error message "Ошибка при записи значения атрибута клиента!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-attr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Temp-hattr

/* Definitions for BROWSE BR-attr                                       */
&Scoped-define FIELDS-IN-QUERY-BR-attr Temp-hattr.attr-code Temp-hattr.attr-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-attr
&Scoped-define SELF-NAME BR-attr
&Scoped-define QUERY-STRING-BR-attr FOR EACH Temp-hattr NO-LOCK WHERE temp-hattr.output-display = YES     BY Temp-hattr.attr-code
&Scoped-define OPEN-QUERY-BR-attr OPEN QUERY {&SELF-NAME} FOR EACH Temp-hattr NO-LOCK WHERE temp-hattr.output-display = YES     BY Temp-hattr.attr-code.
&Scoped-define TABLES-IN-QUERY-BR-attr Temp-hattr
&Scoped-define FIRST-TABLE-IN-QUERY-BR-attr Temp-hattr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-attr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-add b-chg b-del b-help ~
clients-type clients-code clients-name
&Scoped-Define DISPLAYED-OBJECTS clients-type clients-code clients-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить атрибут клиента".

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить атрибут клиента".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить  атрибут клиента".

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1 TOOLTIP "Выход из режима".

DEFINE VARIABLE clients-code AS INTEGER FORMAT ">>>>>>>>>":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9.6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE clients-name AS CHARACTER FORMAT "X(60)":U
      VIEW-AS TEXT
     SIZE 46.8 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE clients-type AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 3.8 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-attr FOR
      Temp-hattr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-attr Dialog-Frame _FREEFORM
  QUERY BR-attr DISPLAY
      Temp-hattr.attr-code COLUMN-LABEL "Атрибут" FORMAT "X(255)":U WIDTH 50
      Temp-hattr.attr-value COLUMN-LABEL "Значение" FORMAT "X(255)":U WIDTH 48
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-add AT ROW 1 COL 21
     b-chg AT ROW 1 COL 31
     b-del AT ROW 1 COL 41
     b-help AT ROW 1 COL 95
     BR-attr AT ROW 4.47 COL 1
     clients-type AT ROW 3.3 COL 19 NO-LABEL
     clients-code AT ROW 3.3 COL 23.4 NO-LABEL
     clients-name AT ROW 3.3 COL 33.8 NO-LABEL
     SPACE(18.49) SKIP(15.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты клиента".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: Temp-hattr T "?" NO-UNDO ub clients-attr
      ADDITIONAL-FIELDS:
          field user-can-edit as logical
          field output-display as logical
          field value_ as character
          field code as char
          INDEX attrc is
          UNIQUE PRIMARY
          obj-type
          obj-code
          code
          INDEX attrcl is UNIQUE
          attr-code
          obj-type
          obj-code
          index ioutput
          output-display
      END-FIELDS.
      TABLE: tt0-clients-attr T "?" NO-UNDO ub clients-attr
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-attr b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BROWSE BR-attr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN clients-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN clients-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN clients-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-attr
/* Query rebuild information for BROWSE BR-attr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH Temp-hattr NO-LOCK WHERE temp-hattr.output-display = YES
    BY Temp-hattr.attr-code.
     _END_FREEFORM
     _OrdList          = "Temp-Tables.Temp-hattr.attr-code|yes"
     _Query            is OPENED
*/  /* BROWSE BR-attr */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Атрибуты клиента */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable loc#log as logical no-undo.
define buffer buf_temp-hattr for temp-hattr.
if add-option = "" then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if add-option = "":U then return no-apply.
run proc-add-chg in this-procedure ( input yes) no-error .
if error-status:error then do:
  add-option = "":U.
  return no-apply.
end.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
find first buf_temp-hattr no-lock where
                        buf_temp-hattr.code = add-option no-error.
add-option = "":U.
if avail buf_temp-hattr then
    temp-doc-rec = recid(buf_temp-hattr).
    else temp-doc-rec = ?.
reposition BR-attr to recid temp-doc-rec no-error.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not avail temp-hattr then return no-apply.
  run proc-add-chg in this-procedure ( input no ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable loc#log as logical no-undo.
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if not avail temp-hattr then return no-apply.
  run clntattr-code in this-procedure (
                                        input  temp-hattr.code
                                        ,output attr-type
                                        ,output attr-format
                                        ,output attr-label
                                        ,output attr-user-can-edit
                                        ,output attr-output-display
                                        ,output attr-other
                                        ) .
  if not attr-user-can-edit then do:
    message
    "Атрибут нельзя удалить вручную"
    view-as alert-box error .
    return no-apply.
  end.
  glog = no.
  message
  "Вы уверены, что хотите удалить атрибут " temp-hattr.attr-code skip
  " для клиента " clients-name
  view-as alert-box QUESTIOn buttons YES-NO update glog.
  if NOT glog then return no-apply.
    DELETE temp-hattr.
    updated = yes.
   {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
   RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-attr
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
 { gbl/app_help.i }
{ gbl/brwrepos.i
&line-num=5
}

{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if NOT (p-mode = {&lookup}
        or p-mode = {&update}
        or p-mode = {&add-def}
        ) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова p-mode" p-mode
    view-as alert-box ERROR.
    return error.
  end.
  { ref/attr-pop.i prepare }
  RUN MyEnable in this-procedure .
  Run init-proc in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .
run attr-pop-clean-up in this-procedure ( input {&table_clients-attr} ).
if updated then return {&update}.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-to-edit Dialog-Frame
PROCEDURE choose-to-edit :
define input parameter p-attr-code as character no-undo .
assign
add-option = p-attr-code
.
APPLY "CHOOSE" to b-add in frame {&frame-name} .
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
  DISPLAY clients-type clients-code clients-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-add b-chg b-del b-help clients-type clients-code
         clients-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
define var  attr-type as character no-undo .          /* тип атрибута      */
define var  attr-format as character no-undo .        /* формат атрибута   */
define var  attr-label as character no-undo .         /* лабел атрибута    */
define var  attr-value as character no-undo .         /* значение атрибута */
define var  attr-user-can-edit as logical no-undo .   /* пользователь может изменять в броусе */
define var  attr-output-display as logical no-undo .  /* виден в броусе    */
define var  attr-other as char no-undo .              /* еще чего - нибудь */
DEFINE BUFFER buf_clients FOR ub.clients.
for each  Temp-hattr:
  delete Temp-hattr.
end.

add-option = "".
IF p-mode <> {&add-def} THEN DO:
    find first buf_clients where buf_clients.obj-code =  p-obj-code
                   and buf_clients.obj-type =  p-obj-type

        no-lock no-error .
    Assign
        clients-type = buf_clients.obj-type
        clients-code = buf_clients.obj-code
        clients-name = buf_clients.obj-name

        .
  display
  clients-type
  clients-code
  clients-name
  with frame {&frame-name}  .

END.

   For each tt0-clients-attr where
            tt0-clients-attr.obj-code = p-obj-code and
            tt0-clients-attr.obj-type  = p-obj-type
            no-lock :
    run clntattr-code in this-procedure (
                                          input tt0-clients-attr.attr-code
                                          ,output attr-type
                                          ,output attr-format
                                          ,output attr-label
                                          ,output attr-user-can-edit
                                          ,output attr-output-display
                                          ,output attr-other ).
    run clntattr-value in this-procedure (
                          input tt0-clients-attr.obj-type
                        ,input tt0-clients-attr.obj-code
                        ,input tt0-clients-attr.attr-code
                        ,output attr-value
                        ,output attr-type ).

      create Temp-hattr.
      assign
      Temp-hattr.obj-type = tt0-clients-attr.obj-type
      Temp-hattr.obj-code = tt0-clients-attr.obj-code
      Temp-hattr.attr-code = (if attr-output-display
                              then attr-label
                              else tt0-clients-attr.attr-code)
      temp-hattr.value_ = attr-value
      Temp-hattr.attr-value = (if attr-type = {&type-log}
                              then string(attr-value = "yes":U, attr-format)
                              else attr-value)
      Temp-hattr.user-can-edit = attr-user-can-edit
      Temp-hattr.output-display = attr-output-display
      Temp-hattr.code = tt0-clients-attr.attr-code
      .
    End.   /* FOR EACH */
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
b-add:POPUP-MENU IN FRAME {&frame-name}  = MENU MENU-b-ins:HANDLE
b-add:MENU-MOUSE = 1
Temp-hattr.attr-code:RESIZABLE IN BROWSE br-attr = YES
Temp-hattr.attr-value:RESIZABLE IN BROWSE br-attr = YES
.
assign
v-tab-order = "b-exit,b-quit,b-add,b-chg,b-del,b-help,br-attr".
if p-mode <> {&lookup} then do:
  run attr-pop-create-items in this-procedure  (
                                                 input {&table_clients-attr}
                                                ,input 'clntattr-manual-edit'   /*p-get-section-num-proc-name*/
                                                ,input 'clntattr-tooltip'
                                                ,input 'choose-to-edit'
                                                ,input menu menu-b-ins:handle
                                                ,input {&clntattr-list}
                                              ).
end.

ENABLE
b-exit when p-mode <> {&lookup}
b-quit
b-del when p-mode <> {&lookup}
b-add when p-mode <> {&lookup}
b-chg when p-mode <> {&lookup}
b-help BR-attr
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
 if p-mode = {&lookup} then do:
    hide
    b-exit
    in frame {&frame-name} .
    assign
    b-quit:label = "&Выход"
    b-quit:col    = 1
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-chg Dialog-Frame
PROCEDURE proc-add-chg :
define input parameter p-add as logical no-undo .
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable attr-value as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-init as character no-undo .
define var loc#log as logical no-undo.
DEFINE VARIABLE v-spr as character no-undo .
DEFINE VARIABLE v-setted as logical no-undo .
define variable jj as integer no-undo .

case p-add:
  when yes then do:
    run temp-clntattr-exist in this-procedure (
                                                input p-obj-type
                                                ,input p-obj-code
                                                ,input add-option
                                                ,output loc#log)  no-error.
    if error-status:error or loc#log then return error.
    run clntattr-code in this-procedure (
                                          input  add-option          /* p-code           */
                                          ,output attr-type           /* p-type           */
                                          ,output attr-format         /* p-format         */
                                          ,output attr-label          /* p-label          */
                                          ,output attr-user-can-edit  /* p-user-can-edit  */
                                          ,output attr-output-display /* p-output-display */
                                          ,output attr-other          /* p-other          */
                                          ) no-error .
    if error-status :error then do:
      return error .
    end.
    CASE attr-type:
      when {&type-log} then do:
        assign
        v-attr-value = "yes":U
        .
      end.
      when {&type-int} or when {&type-dec} then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-value
                      else string(0)
        .
      end.
      when {&type-date} then do:
        assign
        v-attr-value = ?
        .
      end.
      when {&type-char} then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-value
                      else "":U
        .
      end.
    END CASE.
    assign
    attr-value = v-attr-value
    .
  end.
  when no then do:
    run clntattr-code in this-procedure (
                                          input TEMP-hattr.code
                                          ,output attr-type
                                          ,output attr-format
                                          ,output attr-label
                                          ,output attr-user-can-edit
                                          ,output attr-output-display
                                          ,output attr-other) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
        {&cliattr-type-get-error}
        return error.
    END.
    assign
    attr-value = temp-hattr.value_
    .
  end.
END CASE.
IF attr-user-can-edit Then DO:
  do jj = 1 to num-entries(attr-other, {&slash-char}):
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr":U
    then do:
      assign
      v-spr = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
  end.
if v-spr = "":u then do:
  run gbl/d-prompt.w (
    'title=':u + "Изменение атрибута клиента" + '\':u
  + 'text1=':u + attr-label + '\':u
  + 'format=' + (if attr-type = {&type-log} then "yes/no" else attr-format) + '\':u
  + 'type=' + attr-type + '\':u
  + 'fillin_row=2\':u
  + 'fillin_col=4\':u
  + 'fillin_width=20\':u
  + 'fillin_height=1\':u
  + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
  + 'readonly=' + (if p-mode = {&lookup} then 'yes':u else 'no':u) + '\':u
  , input-output attr-value
      ).
  if return-value = 'false':u then return error.

end.
else do:
  run  value(v-spr) in this-procedure (
                                       input p-obj-type
                                      ,input p-obj-code
                                      ,input-output attr-value
                                      ,output v-setted) no-error .
  if not v-setted then return error.
end.
  run temp-clntattr-write in this-procedure (
                                    input p-obj-type
                                    ,input p-obj-code
                                    ,input (if p-add then add-option else temp-hattr.code)
                                    ,input attr-value
                                   ) no-error .
  IF NOT error-status:error then do:
      assign
      updated = yes
      .
      br-attr:refresh() in frame {&frame-name} no-error .
  END.
End.
Else message "Изменение атрибута невозможно !" view-as alert-box error.

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
DEFINE VARIABLE v-updated AS LOGICAL NO-UNDO.
define variable v-created as logical no-undo .
define variable v-deleted as logical no-undo .
define variable v-updated-str as character no-undo .
define variable v-type as character no-undo .
for each temp-hattr NO-LOCK where
       temp-hattr.obj-type = p-obj-type
   AND temp-hattr.obj-code = p-obj-code :
  if temp-hattr.output-display = no then next.
   find first tt0-clients-attr NO-LOCK WHERE
          tt0-clients-attr.obj-type = temp-hattr.obj-type
    AND   tt0-clients-attr.obj-code = temp-hattr.obj-code
    AND   tt0-clients-attr.attr-code = temp-hattr.code no-error.
  assign
  v-updated = no.
  if available  tt0-clients-attr then do:
    BUFFER-COMPARE temp-hattr
                TO tt0-clients-attr
                case-sensitive
                SAVE result IN v-updated-str.
    assign
    v-created = yes
    v-updated = (v-updated-str <> "":U)
    .
  end.
  else do:
    assign
    v-updated = yes.
  end.
  if v-updated then do:
    run tt0-clntattr-write in this-procedure (
                                     input p-obj-type
                                    ,input p-obj-code
                                    ,input temp-hattr.code
                                    ,input temp-hattr.value_)  no-error.
    if error-status:error then do:
      message
      "Ошибка при сохранении атрибута клиента" skip
      "тип" p-obj-type SKIP
      "код" p-obj-code SKIP
      "Атрибут" temp-hattr.attr-code skip
      error-status:get-message(1) skip
      return-value
      view-as alert-box  error .
      undo, return error  .
    end.
    updated = yes.
  end.
  ASSIGN
  p-updated = v-updated OR p-updated.
End.
FOR EACH tt0-clients-attr where
         tt0-clients-attr.obj-type = p-obj-type
    AND  tt0-clients-attr.obj-code = p-obj-code:
  FIND FIRST temp-hattr NO-LOCK WHERE
            temp-hattr.obj-type = tt0-clients-attr.obj-type
        AND temp-hattr.obj-code = tt0-clients-attr.obj-code
        AND temp-hattr.code = tt0-clients-attr.attr-code NO-ERROR.
    IF NOT AVAILABLE temp-hattr THEN DO:
      DELETE tt0-clients-attr.
      assign
      v-deleted = yes.
      ASSIGN
      p-updated = (v-deleted OR p-updated).
    END.
END.
if p-updated
and p-update-instantly then do:
  run ref/cli-atr1.p (
                     input p-mode
                    ,input p-obj-type
                    ,input p-obj-code
                    ,INPUT table tt0-clients-attr
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении атрибутов клиента:&1&2&1&3"
               , {&new-line}
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
    undo, return error .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-clntattr-exist Dialog-Frame
PROCEDURE temp-clntattr-exist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
    define input parameter p-code     like ub.clients-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .

    define buffer buf_temp-hattr for temp-hattr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run clntattr-code in this-procedure (
                                          input  p-code           /* p-code           */
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

    find first buf_temp-hattr no-lock
      where buf_temp-hattr.obj-type  = p-obj-type
        and buf_temp-hattr.obj-code  = p-obj-code
        and buf_temp-hattr.attr-code = p-code
      no-error .
    if  available buf_temp-hattr then do:
      p-exist = yes.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-clntattr-write Dialog-Frame
PROCEDURE temp-clntattr-write :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
    define input parameter p-code     like ub.clients-attr.attr-code  no-undo .
    define input parameter p-value    like ub.clients-attr.attr-value no-undo .

    define buffer buf_temp-hattr for temp-hattr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run clntattr-code in this-procedure (
                                          input  p-code           /* p-code           */
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

    find first buf_temp-hattr exclusive-lock
      where buf_temp-hattr.obj-type  = p-obj-type
        and buf_temp-hattr.obj-code  = p-obj-code
        and buf_temp-hattr.code = p-code
      no-error .
    if not available buf_temp-hattr then do:
      create buf_temp-hattr .
      assign
        buf_temp-hattr.obj-type  = p-obj-type
        buf_temp-hattr.obj-code  = p-obj-code
        buf_temp-hattr.attr-code = v-label
        buf_temp-hattr.code      = p-code
        buf_temp-hattr.attr-value = (if v-type = {&type-log} then string(logical(p-value), v-format) else p-value)
        buf_temp-hattr.value_ = p-value
        buf_Temp-hattr.output-display = v-output-display
      .
    end.
    assign
    buf_temp-hattr.value_ = p-value
    buf_temp-hattr.attr-value = (if v-type = {&type-log} then string(logical(p-value), v-format) else p-value)
    .
    release buf_temp-hattr no-error.
    if error-status:error then do:
      return error substitute("Ошибка при сохранение атрибута &1 клиента &2&3: &4 &5"
                             , p-code
                             , p-obj-type
                             , p-obj-code
                             , error-status:get-message(1)
                             , return-value ).
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tt0-clntattr-write Dialog-Frame
PROCEDURE tt0-clntattr-write :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define input parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
    define input parameter p-code     like ub.clients-attr.attr-code  no-undo .
    define input parameter p-value    like ub.clients-attr.attr-value no-undo .

    define buffer buf_tt0-clients-attr for tt0-clients-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run clntattr-code in this-procedure (
                                          input  p-code           /* p-code           */
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

    find first buf_tt0-clients-attr exclusive-lock
      where buf_tt0-clients-attr.obj-type  = p-obj-type
        and buf_tt0-clients-attr.obj-code  = p-obj-code
        and buf_tt0-clients-attr.attr-code = p-code
      no-error .
    if not available buf_tt0-clients-attr then do:
      create buf_tt0-clients-attr .
      assign
        buf_tt0-clients-attr.obj-type  = p-obj-type
        buf_tt0-clients-attr.obj-code  = p-obj-code
        buf_tt0-clients-attr.attr-code = p-code
      .
    end.
    assign
      buf_tt0-clients-attr.attr-value = p-value
    .
    release buf_tt0-clients-attr no-error.
    if error-status:error then do:
      return error RETURN-VALUE.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME