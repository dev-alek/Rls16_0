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

Глобальные параметры для блока Взаиморасчеты

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
define buffer buf_thbj-attr for ub.thbj-attr.

define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define temp-table thbjattr_thbj-attr-fin no-undo like ub.thbj-attr.
define variable v-tth-abc as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-abc as logical no-undo.
define variable str-attr as character no-undo .

assign
v-tth-abc = buffer thbjattr_thbj-attr-fin:table-handle .

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
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-Help I-fo-buyer-nws ~
I-fo-supp-nws I-fo-fact I-add-conn-avt I-del-conn-avt I-fo-mc-mode I-fo-gen ~
fo-buyer-nws fo-supp-nws fo-fact fo-mc-mode add-conn-avt del-conn-avt ~
fo-gen-ord fo-nakl-status_ fo-gen-nakl v-fo-buyer-nws v-fo-supp-nws ~
v-fo-mc-mode v-fo-gen v-stat-text 
&Scoped-Define DISPLAYED-OBJECTS fo-buyer-nws fo-supp-nws fo-fact ~
fo-mc-mode add-conn-avt del-conn-avt fo-gen-ord fo-nakl-status_ fo-gen-nakl ~
v-fo-buyer-nws v-fo-supp-nws v-fo-mc-mode v-fo-gen v-stat-text 

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

DEFINE VARIABLE fo-nakl-status_ AS CHARACTER FORMAT "X(256)":U INITIAL "накл +" 
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "накл +","разр","факт" 
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE v-fo-buyer-nws AS CHARACTER FORMAT "X(256)":U INITIAL "1" 
      VIEW-AS TEXT 
     SIZE 81 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-fo-gen AS CHARACTER FORMAT "X(256)":U INITIAL "4" 
      VIEW-AS TEXT 
     SIZE 81 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-fo-mc-mode AS CHARACTER FORMAT "X(256)":U INITIAL "3" 
      VIEW-AS TEXT 
     SIZE 81 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-fo-supp-nws AS CHARACTER FORMAT "X(256)":U INITIAL "2" 
      VIEW-AS TEXT 
     SIZE 81 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-stat-text AS CHARACTER FORMAT "X(256)":U INITIAL "в статусе" 
      VIEW-AS TEXT 
     SIZE 10 BY .63 NO-UNDO.

DEFINE IMAGE I-add-conn-avt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.75.

DEFINE IMAGE I-del-conn-avt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.75.

DEFINE IMAGE I-fo-buyer-nws
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 2.04.

DEFINE IMAGE I-fo-fact
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .75.

DEFINE IMAGE I-fo-gen
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.75.

DEFINE IMAGE I-fo-mc-mode
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 2.04.

DEFINE IMAGE I-fo-supp-nws
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.75.

DEFINE VARIABLE fo-buyer-nws AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Создаются на активной стороне", 0,
"Только в ГБД", 1
     SIZE 33.75 BY 2 NO-UNDO.

DEFINE VARIABLE fo-mc-mode AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Простая (старая схема)", 0,
"Мастер договор", 1,
"Смешанная схема", 2
     SIZE 41.25 BY 2 NO-UNDO.

DEFINE VARIABLE fo-supp-nws AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Не ходят по новостям", 0,
"Из ГБД в УБД", 1
     SIZE 32.25 BY 2 NO-UNDO.

DEFINE VARIABLE add-conn-avt AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .83 NO-UNDO.

DEFINE VARIABLE del-conn-avt AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .83 NO-UNDO.

DEFINE VARIABLE fo-fact AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .83 NO-UNDO.

DEFINE VARIABLE fo-gen-nakl AS LOGICAL INITIAL no 
     LABEL "Накладных" 
     VIEW-AS TOGGLE-BOX
     SIZE 15.25 BY .79
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fo-gen-ord AS LOGICAL INITIAL no 
     LABEL "Заказов" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY .79
     FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 74.5
     fo-buyer-nws AT ROW 3 COL 4.75 NO-LABEL WIDGET-ID 2
     fo-supp-nws AT ROW 6 COL 4.75 NO-LABEL WIDGET-ID 12
     fo-fact AT ROW 8.58 COL 5 WIDGET-ID 38
     fo-mc-mode AT ROW 11.5 COL 5 NO-LABEL WIDGET-ID 44
     add-conn-avt AT ROW 14.25 COL 5.5 WIDGET-ID 38
     del-conn-avt AT ROW 15.92 COL 5.5 WIDGET-ID 38
     fo-gen-ord AT ROW 18.46 COL 5.5 WIDGET-ID 60
     fo-nakl-status_ AT ROW 19.25 COL 25.88 COLON-ALIGNED NO-LABEL WIDGET-ID 64
     fo-gen-nakl AT ROW 19.42 COL 5.5 WIDGET-ID 62
     v-fo-buyer-nws AT ROW 2.25 COL 1.5 NO-LABEL WIDGET-ID 6
     v-fo-supp-nws AT ROW 5.25 COL 1.5 NO-LABEL WIDGET-ID 18
     v-fo-mc-mode AT ROW 10.25 COL 1.5 NO-LABEL WIDGET-ID 40
     v-fo-gen AT ROW 17.25 COL 1.75 NO-LABEL WIDGET-ID 70
     v-stat-text AT ROW 19.46 COL 15.75 COLON-ALIGNED NO-LABEL WIDGET-ID 68
     I-fo-buyer-nws AT ROW 2.96 COL 1 WIDGET-ID 10
     I-fo-supp-nws AT ROW 6 COL 1 WIDGET-ID 34
     I-fo-fact AT ROW 8.58 COL 1 WIDGET-ID 36
     I-add-conn-avt AT ROW 14.25 COL 1.5 WIDGET-ID 36
     I-del-conn-avt AT ROW 15.92 COL 1.5 WIDGET-ID 36
     I-fo-mc-mode AT ROW 11.25 COL 1 WIDGET-ID 42
     I-fo-gen AT ROW 18.42 COL 1 WIDGET-ID 58
     SPACE(83.12) SKIP(0.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки для блока Взаиморасчеты"
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

/* SETTINGS FOR FILL-IN v-fo-buyer-nws IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-fo-buyer-nws:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-fo-gen IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-fo-gen:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-fo-mc-mode IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-fo-mc-mode:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-fo-supp-nws IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-fo-supp-nws:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       v-stat-text:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Настройки для блока Взаиморасчеты */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки для блока Взаиморасчеты */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fo-gen-nakl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fo-gen-nakl Dialog-Frame
ON VALUE-CHANGED OF fo-gen-nakl IN FRAME Dialog-Frame /* Накладных */
DO:
  IF fo-gen-nakl:SCREEN-VALUE = "yes" THEN DO :
     enable  fo-nakl-status_ v-stat-text with frame {&frame-name} .
     display fo-nakl-status_ v-stat-text with frame {&frame-name} .
  end.
  ELSE HIDE fo-nakl-status_ v-stat-text in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-add-conn-avt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-add-conn-avt Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-add-conn-avt IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-del-conn-avt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-del-conn-avt Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-del-conn-avt IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-fo-buyer-nws
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-fo-buyer-nws Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-fo-buyer-nws IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-fo-fact
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-fo-fact Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-fo-fact IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-fo-gen
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-fo-gen Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-fo-gen IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-fo-mc-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-fo-mc-mode Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-fo-mc-mode IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-fo-supp-nws
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-fo-supp-nws Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-fo-supp-nws IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
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
  DISPLAY fo-buyer-nws fo-supp-nws fo-fact fo-mc-mode add-conn-avt del-conn-avt 
          fo-gen-ord fo-nakl-status_ fo-gen-nakl v-fo-buyer-nws v-fo-supp-nws 
          v-fo-mc-mode v-fo-gen v-stat-text 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help I-fo-buyer-nws I-fo-supp-nws I-fo-fact 
         I-add-conn-avt I-del-conn-avt I-fo-mc-mode I-fo-gen fo-buyer-nws 
         fo-supp-nws fo-fact fo-mc-mode add-conn-avt del-conn-avt fo-gen-ord 
         fo-nakl-status_ fo-gen-nakl v-fo-buyer-nws v-fo-supp-nws v-fo-mc-mode 
         v-fo-gen v-stat-text 
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

for each thbjattr_thbj-attr-fin:
  delete thbjattr_thbj-attr-fin.
end.
for each temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
    input "init":U
  , input ""
  , input 0
  , input {&attr-fin-global}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth-abc
  ) no-error .
if error-status:error
and not available buf_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.


FOR EACH thbjattr_thbj-attr-fin:
  IF thbjattr_thbj-attr-fin.prop-code = {&attr-fin-global_fo-buyer-nws} THEN DO:
     fo-buyer-nws = thbjattr_thbj-attr-fin.property-value-integer.
     fo-buyer-nws:PRIVATE-DATA IN FRAME {&FRAME-NAME} = "recid=" + string(recid(thbjattr_thbj-attr-fin)).
     display fo-buyer-nws with frame {&frame-name} .
  END.
  IF thbjattr_thbj-attr-fin.prop-code = {&attr-fin-global_fo-supp-nws} THEN DO:
     fo-supp-nws = thbjattr_thbj-attr-fin.property-value-integer.
     fo-supp-nws:private-data = "recid=" + string(recid(thbjattr_thbj-attr-fin)).
     display fo-supp-nws with frame {&frame-name} .
  END.
  IF thbjattr_thbj-attr-fin.prop-code = {&attr-fin-global_fo-fact} THEN DO:
     fo-fact = thbjattr_thbj-attr-fin.property-value-logical.
     fo-fact:private-data = "recid=" + string(recid(thbjattr_thbj-attr-fin)).
     display fo-fact with frame {&frame-name} .
  END.
  IF thbjattr_thbj-attr-fin.prop-code = {&attr-fin-global_fo-mc-mode} THEN DO:
     fo-mc-mode = thbjattr_thbj-attr-fin.property-value-integer.
     fo-mc-mode:private-data = "recid=" + string(recid(thbjattr_thbj-attr-fin)).
     display fo-mc-mode with frame {&frame-name} .
  END.
  IF thbjattr_thbj-attr-fin.prop-code = {&attr-fin-global_add-conn-avt} THEN DO:
     add-conn-avt = thbjattr_thbj-attr-fin.property-value-logical.
     add-conn-avt:private-data = "recid=" + string(recid(thbjattr_thbj-attr-fin)).
     display add-conn-avt with frame {&frame-name} .
  END.
  IF thbjattr_thbj-attr-fin.prop-code = {&attr-fin-global_del-conn-avt} THEN DO:
     del-conn-avt = thbjattr_thbj-attr-fin.property-value-logical.
     del-conn-avt:private-data = "recid=" + string(recid(thbjattr_thbj-attr-fin)).
     display del-conn-avt with frame {&frame-name} .
  END.  
  IF thbjattr_thbj-attr-fin.prop-code = {&attr-fin-global_fo-gen} THEN DO:
     fo-gen-ord = if ((thbjattr_thbj-attr-fin.property-value-integer + 1) MODULO 2 = 0) then true else false.
     display fo-gen-ord with frame {&frame-name} .

     fo-gen-nakl = if (thbjattr_thbj-attr-fin.property-value-integer >= 2) then true else false.
     display fo-gen-nakl with frame {&frame-name} .

          if (thbjattr_thbj-attr-fin.property-value-integer = 2 or thbjattr_thbj-attr-fin.property-value-integer = 3) then fo-nakl-status_ = "накл +".
     else if (thbjattr_thbj-attr-fin.property-value-integer = 4 or thbjattr_thbj-attr-fin.property-value-integer = 5) then fo-nakl-status_ = "разр"  .
     else if (thbjattr_thbj-attr-fin.property-value-integer = 6 or thbjattr_thbj-attr-fin.property-value-integer = 7) then fo-nakl-status_ = "факт"  .
     display fo-nakl-status_ with frame {&frame-name} .
          if (thbjattr_thbj-attr-fin.property-value-integer = 0 or thbjattr_thbj-attr-fin.property-value-integer = 1) then
                                    hide v-stat-text fo-nakl-status_ in frame {&frame-name} .
  END.

  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-fin to temp-thbj-attr.
END.


define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .

run thbjattr_tooltip in this-procedure (
             input   {&attr-fin-global}
            ,input  "fo-buyer-nws"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-fo-buyer-nws:screen-value = entry(2,v-label,":") .
I-fo-buyer-nws:private-data = v-tooltip-code .

run thbjattr_tooltip in this-procedure (
             input   {&attr-fin-global}
            ,input  "fo-supp-nws"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .

v-fo-supp-nws:screen-value = entry(2,v-label,":") .
I-fo-supp-nws:private-data = v-tooltip-code .

run thbjattr_tooltip in this-procedure (
             input   {&attr-fin-global}
            ,input  "fo-fact"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .

/* Для корректного отображения крайней буквы :)  */
fo-fact:label = entry(2,v-label,":") + "                                    _".
I-fo-fact:private-data = v-tooltip-code .

run thbjattr_tooltip in this-procedure (
             input   {&attr-fin-global}
            ,input  "fo-mc-mode"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
           .

v-fo-mc-mode:screen-value = entry(2,v-label,":") .
I-fo-mc-mode:private-data = v-tooltip-code .


run thbjattr_tooltip in this-procedure (
             input   {&attr-fin-global}
            ,input  "add-conn-avt"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
                            .
add-conn-avt:label = entry(2,v-label,":") .
I-add-conn-avt:private-data = v-tooltip-code .

run thbjattr_tooltip in this-procedure (
             input   {&attr-fin-global}
            ,input  "del-conn-avt"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
                            .
del-conn-avt:label = entry(2,v-label,":") .
I-del-conn-avt:private-data = v-tooltip-code .

run thbjattr_tooltip in this-procedure (
             input   {&attr-fin-global}
            ,input  "fo-gen"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .

v-fo-gen:screen-value = entry(2,v-label,":") .
I-fo-gen:private-data = v-tooltip-code .

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
        and   buf_thbj-attr.upper-prop-code = {&attr-fin-global}
        and   buf_thbj-attr.prop-code = '':u no-wait no-error.
     if locked buf_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-fin-global} skip
        "Запись Глобальных ПАРАМЕТРОВ для взаиморасчетов  занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first buf_thbj-attr no-lock where
          buf_thbj-attr.obj-type = ""
    and   buf_thbj-attr.obj-code = 0
    and   buf_thbj-attr.upper-prop-code = {&attr-fin-global}
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
  apply "value-changed":u to fo-buyer-nws in frame {&frame-name}.
  if p-mode <> {&update} then do:
     disable fo-buyer-nws
             fo-supp-nws
             fo-fact
             fo-mc-mode
             add-conn-avt
             del-conn-avt
                         fo-gen-ord
             fo-gen-nakl
             fo-nakl-status_
             with frame {&frame-name}.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame {&frame-name} .
     if not fo-gen-nakl then hide fo-nakl-status_ v-stat-text in frame {&frame-name} .
     else v-stat-text:FGCOLOR = 7 .
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
    fo-buyer-nws  FRAME {&FRAME-NAME}
    fo-supp-nws
    fo-fact
    fo-mc-mode
    add-conn-avt
    del-conn-avt
    fo-gen-ord
    fo-gen-nakl
    fo-nakl-status_
    .

 assign
    fh = frame {&frame-name}:first-child
    wh = fh:first-child
    .

do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr-fin where
              recid(thbjattr_thbj-attr-fin) = integer(entry(2, wh:private-data, '=')).

    assign
    buffer thbjattr_thbj-attr-fin:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
           thbjattr_thbj-attr-fin.obj-type = p-obj-type.
           thbjattr_thbj-attr-fin.obj-code = p-obj-code.
  end.
  wh = wh:next-sibling.
end.
find first thbjattr_thbj-attr-fin where thbjattr_thbj-attr-fin.prop-code = {&attr-fin-global_fo-gen} .
           thbjattr_thbj-attr-fin.obj-type = p-obj-type.
           thbjattr_thbj-attr-fin.obj-code = p-obj-code.

if      not fo-gen-ord and not fo-gen-nakl             then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 0 .
else if     fo-gen-ord and not fo-gen-nakl             then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 1 .
else if not fo-gen-ord and     fo-gen-nakl and fo-nakl-status_ = "накл +"
                                                       then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 2 .
else if     fo-gen-ord and     fo-gen-nakl and fo-nakl-status_ = "накл +"
                                                       then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 3 .
else if not fo-gen-ord and     fo-gen-nakl and fo-nakl-status_ = "разр"
                                                       then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 4 .
else if     fo-gen-ord and     fo-gen-nakl and fo-nakl-status_ = "разр"
                                                       then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 5 .
else if not fo-gen-ord and     fo-gen-nakl and fo-nakl-status_ = "факт"
                                                       then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 6 .
else if     fo-gen-ord and     fo-gen-nakl and fo-nakl-status_ = "факт"
                                                       then assign buffer thbjattr_thbj-attr-fin:buffer-field("property-value-integer"):buffer-value = 7 .
v-same = yes.
for each thbjattr_thbj-attr-fin,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr-fin.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr-fin.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr-fin.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr-fin.prop-code:
   buffer-compare
   thbjattr_thbj-attr-fin
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
      ,input {&attr-fin-global}
      ,input table thbjattr_thbj-attr-fin
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

