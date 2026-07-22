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

Глобальные параметры для накладных

Автор: Чернова Светлана Александровна
Дата создания: 07/04/07
Author: Svetlana Chernova
Creation date: 07/04/07

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
define variable vss-description as character no-undo init "Глобальные параметры для накладных" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
define buffer ord_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define temp-table thbjattr_thbj-attr-trn no-undo like ub.thbj-attr.
define variable v-tth     as handle no-undo .
define variable v-tth-trn as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-trn as logical no-undo.
define variable str-attr as character no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
v-tth-trn = buffer thbjattr_thbj-attr-trn:table-handle .
if g#db-num <> 0 then p-mode = {&lookup} .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-Help I-contr-in-income-NP ~
I-contr-in-expense-NP I-contr-qnty-spec I-contr-in-expense-CPT ~
I-contr-in-income-CPT I-contr-recount B-2 contr-in-income-NP B-3 ~
contr-in-income-CPT B-4 contr-in-expense-NP B-5 contr-in-expense-CPT B-6 ~
contr-qnty-spec B-7 contr-recount v-contr-in-income-NP ~
v-contr-in-income-CPT v-contr-in-expense-NP v-contr-in-expense-CPT ~
v-contr-qnty-spec v-contr-recount 
&Scoped-Define DISPLAYED-OBJECTS contr-in-income-NP contr-in-income-CPT ~
contr-in-expense-NP contr-in-expense-CPT contr-qnty-spec contr-recount ~
v-contr-in-income-NP v-contr-in-income-CPT v-contr-in-expense-NP ~
v-contr-in-expense-CPT v-contr-qnty-spec v-contr-recount 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-2 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-3 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-4 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-5 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-6 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-7 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

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

DEFINE VARIABLE v-contr-in-expense-CPT AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-contr-in-expense-NP AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-contr-in-income-CPT AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-contr-in-income-NP AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-contr-qnty-spec AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE VARIABLE v-contr-recount AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77 BY 1 NO-UNDO.

DEFINE IMAGE I-contr-in-expense-CPT
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-contr-in-expense-NP
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-contr-in-income-CPT
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.

DEFINE IMAGE I-contr-in-income-NP
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.

DEFINE IMAGE I-contr-qnty-spec
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE IMAGE I-contr-recount
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.

DEFINE VARIABLE contr-in-expense-CPT AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY 1 NO-UNDO.

DEFINE VARIABLE contr-in-expense-NP AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY 1 NO-UNDO.

DEFINE VARIABLE contr-in-income-CPT AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY 1 NO-UNDO.

DEFINE VARIABLE contr-in-income-NP AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY 1 NO-UNDO.

DEFINE VARIABLE contr-qnty-spec AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY 1 NO-UNDO.

DEFINE VARIABLE contr-recount AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 80 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 74.5
     B-2 AT ROW 2.96 COL 3 WIDGET-ID 96
     contr-in-income-NP AT ROW 2.96 COL 5.88 WIDGET-ID 44
     B-3 AT ROW 3.96 COL 3 WIDGET-ID 124
     contr-in-income-CPT AT ROW 3.96 COL 5.88 WIDGET-ID 126
     B-4 AT ROW 4.96 COL 3 WIDGET-ID 98
     contr-in-expense-NP AT ROW 4.96 COL 5.88 WIDGET-ID 46
     B-5 AT ROW 5.96 COL 3 WIDGET-ID 116
     contr-in-expense-CPT AT ROW 5.96 COL 5.88 WIDGET-ID 118
     B-6 AT ROW 6.96 COL 3 WIDGET-ID 100
     contr-qnty-spec AT ROW 6.96 COL 5.88 WIDGET-ID 102
     B-7 AT ROW 7.96 COL 3 WIDGET-ID 108
     contr-recount AT ROW 7.96 COL 5.88 WIDGET-ID 110
     v-contr-in-income-NP AT ROW 2.96 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     v-contr-in-income-CPT AT ROW 3.96 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 130
     v-contr-in-expense-NP AT ROW 4.96 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     v-contr-in-expense-CPT AT ROW 5.96 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 122
     v-contr-qnty-spec AT ROW 6.96 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 106
     v-contr-recount AT ROW 7.96 COL 6.75 COLON-ALIGNED NO-LABEL WIDGET-ID 114
     I-contr-in-income-NP AT ROW 3 COL 1 WIDGET-ID 10
     I-contr-in-expense-NP AT ROW 5 COL 1 WIDGET-ID 34
     I-contr-qnty-spec AT ROW 7 COL 1 WIDGET-ID 104
     I-contr-in-expense-CPT AT ROW 6 COL 1 WIDGET-ID 120
     I-contr-in-income-CPT AT ROW 4 COL 1 WIDGET-ID 128
     I-contr-recount AT ROW 8 COL 1 WIDGET-ID 112
     SPACE(83.12) SKIP(5.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки для накладных"
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

ASSIGN 
       v-contr-qnty-spec:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       v-contr-recount:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Настройки для накладных */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки для накладных */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-2 Dialog-Frame
ON CHOOSE OF B-2 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-contr-in},
       {&attr-contr-in_contr-in-income-NP}
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-3 Dialog-Frame
ON CHOOSE OF B-3 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-contr-in},
       {&attr-contr-in_contr-in-income}
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-4 Dialog-Frame
ON CHOOSE OF B-4 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-contr-in},
       {&attr-contr-in_contr-in-expense-NP}
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-5 Dialog-Frame
ON CHOOSE OF B-5 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-contr-in},
       {&attr-contr-in_contr-in-expense}
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-6 Dialog-Frame
ON CHOOSE OF B-6 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-contr-in},
        {&attr-contr-in_contr-qnty-spec}
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-7 Dialog-Frame
ON CHOOSE OF B-7 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-contr-in},
        {&attr-contr-in_contr-recount}
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-contr-in-expense-CPT
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-contr-in-expense-CPT Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-contr-in-expense-CPT IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-contr-in-expense-NP
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-contr-in-expense-NP Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-contr-in-expense-NP IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-contr-in-income-CPT
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-contr-in-income-CPT Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-contr-in-income-CPT IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-contr-in-income-NP
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-contr-in-income-NP Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-contr-in-income-NP IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-contr-qnty-spec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-contr-qnty-spec Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-contr-qnty-spec IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-contr-recount
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-contr-recount Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-contr-recount IN FRAME Dialog-Frame
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
if p-obj-type <> "" then
   frame {&frame-name}:title = frame {&frame-name}:title + (if p-obj-type = {&cmp} then " фирма" else " маг") + string(p-obj-code) .
define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_global-trn_lookup':U
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
    run init-tt.
    run enable_UI.
    run init-proc.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

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
  DISPLAY contr-in-income-NP contr-in-income-CPT contr-in-expense-NP 
          contr-in-expense-CPT contr-qnty-spec contr-recount 
          v-contr-in-income-NP v-contr-in-income-CPT v-contr-in-expense-NP 
          v-contr-in-expense-CPT v-contr-qnty-spec v-contr-recount 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help I-contr-in-income-NP I-contr-in-expense-NP 
         I-contr-qnty-spec I-contr-in-expense-CPT I-contr-in-income-CPT 
         I-contr-recount B-2 contr-in-income-NP B-3 contr-in-income-CPT B-4 
         contr-in-expense-NP B-5 contr-in-expense-CPT B-6 contr-qnty-spec B-7 
         contr-recount v-contr-in-income-NP v-contr-in-income-CPT 
         v-contr-in-expense-NP v-contr-in-expense-CPT v-contr-qnty-spec 
         v-contr-recount 
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

for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
for each thbjattr_thbj-attr-trn:
  delete thbjattr_thbj-attr-trn.
end.

for each temp-thbj-attr:
  delete temp-thbj-attr.
end.

run adm/shattri.p (
    input "init":U
  , input p-obj-type
  , input p-obj-code
  , input {&attr-contr-in}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth-trn
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.


FOR EACH thbjattr_thbj-attr-trn  where
         thbjattr_thbj-attr-trn.obj-type =  p-obj-type and
         thbjattr_thbj-attr-trn.obj-code =  p-obj-code
:
  IF thbjattr_thbj-attr-trn.prop-code = {&attr-contr-in_contr-in-income-NP} THEN DO:
     contr-in-income-NP = thbjattr_thbj-attr-trn.property-value-logical.
     contr-in-income-NP:PRIVATE-DATA IN FRAME {&frame-name}  = "recid2=" + string(recid(thbjattr_thbj-attr-trn)).
     display contr-in-income-NP with frame {&frame-name} .
  end.   
  IF thbjattr_thbj-attr-trn.prop-code = {&attr-contr-in_contr-in-income} THEN DO:
     contr-in-income-CPT = thbjattr_thbj-attr-trn.property-value-logical.
     contr-in-income-CPT:PRIVATE-DATA IN FRAME {&frame-name}  = "recid2=" + string(recid(thbjattr_thbj-attr-trn)).
     display contr-in-income-CPT with frame {&frame-name} .
  END.
  IF thbjattr_thbj-attr-trn.prop-code = {&attr-contr-in_contr-in-expense-NP} THEN DO:
     contr-in-expense-NP = thbjattr_thbj-attr-trn.property-value-logical.
     contr-in-expense-NP:private-data = "recid2=" + string(recid(thbjattr_thbj-attr-trn)).
     display contr-in-expense-NP with frame {&frame-name} .
  END.
  IF thbjattr_thbj-attr-trn.prop-code = {&attr-contr-in_contr-in-expense} THEN DO:
     contr-in-expense-CPT = thbjattr_thbj-attr-trn.property-value-logical.
     contr-in-expense-CPT:private-data = "recid2=" + string(recid(thbjattr_thbj-attr-trn)).
     display contr-in-expense-CPT with frame {&frame-name} .
  END.

  IF thbjattr_thbj-attr-trn.prop-code = {&attr-contr-in_contr-qnty-spec} THEN DO:
     contr-qnty-spec = thbjattr_thbj-attr-trn.property-value-logical.
     contr-qnty-spec:private-data = "recid2=" + string(recid(thbjattr_thbj-attr-trn)).
     display contr-qnty-spec with frame {&frame-name} .
  END.

  IF thbjattr_thbj-attr-trn.prop-code = {&attr-contr-in_contr-recount} THEN DO:
     contr-recount = thbjattr_thbj-attr-trn.property-value-logical.
     contr-recount:private-data = "recid2=" + string(recid(thbjattr_thbj-attr-trn)).
     display contr-recount with frame {&frame-name} .
  END.
  
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-trn to temp-thbj-attr.
END.


define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .


run thbjattr_tooltip in this-procedure (
             input   {&attr-contr-in}
            ,input  "contr-in-income-NP"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-contr-in-income-NP:screen-value = entry(2,v-label,":") .
v-contr-in-income-NP:MOVE-TO-Top( ).
I-contr-in-income-NP:private-data =  REPLACE ( v-tooltip-code , '`' , ',' ).

run thbjattr_tooltip in this-procedure (
             input   {&attr-contr-in}
            ,input  "contr-in-income"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-contr-in-income-CPT:screen-value = entry(2,v-label,":") .
v-contr-in-income-CPT:MOVE-TO-Top( ).
I-contr-in-income-CPT:private-data =  REPLACE ( v-tooltip-code , '`' , ',' ).

run thbjattr_tooltip in this-procedure (
             input   {&attr-contr-in}
            ,input  "contr-in-expense-NP"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-contr-in-expense-NP:screen-value = entry(2,v-label,":") .
v-contr-in-expense-NP:MOVE-TO-Top( ).
I-contr-in-expense-NP:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .

run thbjattr_tooltip in this-procedure (
             input   {&attr-contr-in}
            ,input  "contr-in-expense"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-contr-in-expense-CPT:screen-value = entry(2,v-label,":") .
v-contr-in-expense-CPT:MOVE-TO-Top( ).
I-contr-in-expense-CPT:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .

run thbjattr_tooltip in this-procedure (
             input   {&attr-contr-in}
            ,input  "contr-qnty-spec"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-contr-qnty-spec:screen-value = entry(2,v-label,":") .
v-contr-qnty-spec:MOVE-TO-Top( ).
I-contr-qnty-spec:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .

run thbjattr_tooltip in this-procedure (
             input   {&attr-contr-in}
            ,input  "contr-recount"
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
v-contr-recount:screen-value = entry(2,v-label,":") .
v-contr-recount:MOVE-TO-Top( ).
I-contr-recount:private-data = REPLACE ( v-tooltip-code , '`' , ',' ) .

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
    find first ord_thbj-attr exclusive-lock where
              ord_thbj-attr.obj-type = p-obj-type
        and   ord_thbj-attr.obj-code = p-obj-code
        and   ord_thbj-attr.upper-prop-code = {&attr-contr-in}
        and   ord_thbj-attr.prop-code = '':u no-wait no-error.
     if locked ord_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-contr-in} skip
        "Запись Глобальных ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first ord_thbj-attr no-lock where
          ord_thbj-attr.obj-type = p-obj-type
    and   ord_thbj-attr.obj-code = p-obj-code
    and   ord_thbj-attr.upper-prop-code = {&attr-contr-in}
    and   ord_thbj-attr.prop-code = '':u no-error.
  end.
  if not available ord_thbj-attr then do:
    assign
      v-to-create-trn  = true
      .
    message
    substitute ("Внимание!!!&1Параметра &1 НЕТ в БД!&2Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&attr-contr-in},
                {&new-line})
                 view-as alert-box warning.
  end.

  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> {&update} then do:
     disable
        contr-in-income-CPT
        contr-in-income-NP
        contr-in-expense-CPT
        contr-in-expense-NP
        contr-qnty-spec
        contr-recount
        with frame {&frame-name}.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame {&frame-name} .
  END.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dialog-Frame 
PROCEDURE init-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

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
define variable v-sale-add as character no-undo .
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
    'actn_global-trn_update':U
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
    contr-in-income-CPT FRAME {&FRAME-NAME}
    contr-in-income-NP FRAME {&FRAME-NAME}
    contr-in-expense-CPT FRAME {&FRAME-NAME}
    contr-in-expense-NP FRAME {&FRAME-NAME}
    contr-qnty-spec 
    contr-recount
    .
assign
  fh = frame {&frame-name}:first-child
  wh = fh:first-child
  .

do while valid-handle(wh):
  if wh:private-data begins "recid2=" then do:
    find first thbjattr_thbj-attr-trn where
              recid(thbjattr_thbj-attr-trn) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer thbjattr_thbj-attr-trn:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
           thbjattr_thbj-attr-trn.obj-type = p-obj-type.
           thbjattr_thbj-attr-trn.obj-code = p-obj-code.

  end.

  wh = wh:next-sibling.
end.
v-same = yes.
for each thbjattr_thbj-attr-trn,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr-trn.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr-trn.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr-trn.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr-trn.prop-code:
   buffer-compare
   thbjattr_thbj-attr-trn
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.

v-same = no.
IF v-same  and not v-to-create THEN RETURN.

do TRANSACTION
on error undo, return error return-value
:
  run thbjattr_set-section in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input {&attr-contr-in}
      , input table thbjattr_thbj-attr-trn
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

