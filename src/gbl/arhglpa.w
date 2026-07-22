&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Настройки для АРХИВОВ

Автор: Чернова Светлана Александровна
Дата создания: 02/11/02
Author: Svetlana Chernova
Creation date: 02/11/02

This .W file was created with the Progress AppBuilder.

*/
define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.shop.obj-code no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Глобальные параметры Ассортиментной политики" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
{ gbl/onewin.i   }
define buffer buf_thbj-attr for ub.thbj-attr.

define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define temp-table glb-thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable v-tth-glb as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-abc as logical no-undo.
define variable str-attr as character no-undo .

assign
v-tth-glb = buffer glb-thbjattr_thbj-attr:table-handle .

if p-mode =  {&update} then do:
    if g#db-num = 0 then p-mode = {&update}.
      else p-mode = {&lookup} .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-Help I-apusharh apusharh 
&Scoped-Define DISPLAYED-OBJECTS apusharh 

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
     LABEL "&Help" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE IMAGE I-apusharh
     FILENAME "cmp/info.bmp":U
     SIZE 2 BY 1.

DEFINE VARIABLE apusharh AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 74.5
     apusharh AT ROW 2.75 COL 5 WIDGET-ID 38
     I-apusharh AT ROW 2.75 COL 2.88 WIDGET-ID 36
     SPACE(82.24) SKIP(15.58)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки для АРХИВОВ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
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
ON GO OF FRAME Dialog-Frame /* Настройки для АРХИВОВ */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки для АРХИВОВ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME apusharh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL apusharh Dialog-Frame
ON ALT-I OF apusharh IN FRAME Dialog-Frame
DO:
  MESSAGE i-{&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-apusharh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-apusharh Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-apusharh IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-apusharh Dialog-Frame
ON SELECTION OF I-apusharh IN FRAME Dialog-Frame
DO:
  MESSAGE 's' .
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
if p-obj-type <> "" then
   frame {&frame-name}:title = frame {&frame-name}:title + (if p-obj-type = {&cmp} then " фирма" else " маг") + string(p-obj-code) .

define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_global-fin_lookup':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return error. end.
    RUN init-tt.
    RUN enable_UI.
    RUN init-proc.

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
  DISPLAY apusharh 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help I-apusharh apusharh 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .

for each glb-thbjattr_thbj-attr:
  delete glb-thbjattr_thbj-attr.
end.
for each temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
    input "init":U
  , input ""
  , input 0
  , input {&attr-arh-global}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth-glb
  ) no-error .
if error-status:error
and not available buf_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.


FOR EACH glb-thbjattr_thbj-attr:
  IF glb-thbjattr_thbj-attr.prop-code = {&attr-arh-global_apusharh} THEN DO:
     apusharh = glb-thbjattr_thbj-attr.property-value-logical.
     apusharh:private-data in frame {&frame-name}  = "recid=" + string(recid(glb-thbjattr_thbj-attr)).
     display apusharh with frame {&frame-name} .
  END.
  create temp-thbj-attr.
  buffer-copy glb-thbjattr_thbj-attr to temp-thbj-attr.
END.


define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .


run thbjattr_tooltip in this-procedure (
             input   {&attr-arh-global}
            ,input  "apusharh"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
apusharh:label          = REPLACE ( entry(2,v-label,":") , "`" , "," ) .
I-apusharh:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame 
PROCEDURE init-proc :
define variable v-i as integer   no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-type as character no-undo .
define variable v-value as character no-undo .
define variable v-found as decimal   no-undo .
  if p-mode = {&update} then do:
    find first buf_thbj-attr exclusive-lock where
              buf_thbj-attr.obj-type = ""
        and   buf_thbj-attr.obj-code = 0
        and   buf_thbj-attr.upper-prop-code = {&attr-arh-global}
        and   buf_thbj-attr.prop-code = '':u no-wait no-error.
     if locked buf_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-arh-global} skip
        "Запись Глобальных ПАРАМЕТРОВ для взаиморасчетов  занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first buf_thbj-attr no-lock where
          buf_thbj-attr.obj-type = ""
    and   buf_thbj-attr.obj-code = 0
    and   buf_thbj-attr.upper-prop-code = {&attr-arh-global}
    and   buf_thbj-attr.prop-code = '':u no-error.
  end.
  if not available buf_thbj-attr then do:
    assign
      v-to-create  = true
      .
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
                 view-as alert-box warning.
  end.

  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> {&update} then do:
     disable apusharh  with frame {&frame-name}.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame {&frame-name} .
  END.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dialog-Frame 
PROCEDURE init-tt :
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame 
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-trf-type like ub.clients.obj-type no-undo .
define variable v-trf-code like ub.clients.obj-code no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
IF p-mode = {&LOOKUP} THEN RETURN .
define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_global-fin_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return error. end.

ASSIGN
     FRAME {&FRAME-NAME}
    apusharh
    .

 assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:
    find first glb-thbjattr_thbj-attr where
              recid(glb-thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).

    assign
    buffer glb-thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
           glb-thbjattr_thbj-attr.obj-type = p-obj-type.
           glb-thbjattr_thbj-attr.obj-code = p-obj-code.
  end.
  wh = wh:next-sibling.
end.
v-same = yes.
for each glb-thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = glb-thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = glb-thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = glb-thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = glb-thbjattr_thbj-attr.prop-code:
   buffer-compare
   glb-thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.


do TRANSACTION
on error undo, return error return-value
:

  run thbjattr_set-section in this-procedure (
       input ""
      ,input 0
      ,input {&attr-arh-global}
      ,input table glb-thbjattr_thbj-attr
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.


end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

