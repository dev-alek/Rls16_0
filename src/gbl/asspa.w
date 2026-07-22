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

Настройки Ассортиментной политики

Автор: Чернова Светлана Александровна
Дата создания: 08/03/09
Author: Svetlana Chernova
Creation date: 08/03/09

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode        as character no-undo.
define input parameter p-obj-type    like ub.clients.obj-type no-undo.
define input parameter p-obj-code    like ub.shop.obj-code no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/onewin.i   }
define buffer obj_thbj-attr for ub.thbj-attr.
define buffer glb_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth     as handle no-undo .
define variable v-tthg    as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-trn as logical no-undo.
define variable v-to-create-trn-g as logical no-undo.
define variable str-attr as character no-undo .
define temp-table thbjattr_thbj-attr-g no-undo like thbjattr_thbj-attr .

assign
v-tth  = buffer thbjattr_thbj-attr:table-handle .
v-tthg = buffer thbjattr_thbj-attr-g:table-handle .
 if g#db-num <> 0 and p-obj-type = "" and  p-obj-code = 0
    then p-mode = {&lookup} .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit I-ass-srokiztdel I-crit-srokgod ~
I-ass-num-days-igt I-ass-proc-matr-shabl B-quit B-Help B-6 ass-srokiztdel ~
crit-srokgod B-7 B-8 ass-num-days-igt B-9 ass-proc-matr-shabl ~
v-ass-srokiztdel v-crit-srokgod v-Ass-Num-days-igt v-Ass-proc-matr-shabl 
&Scoped-Define DISPLAYED-OBJECTS ass-srokiztdel crit-srokgod ~
ass-num-days-igt ass-proc-matr-shabl v-ass-srokiztdel v-crit-srokgod ~
v-Ass-Num-days-igt v-Ass-proc-matr-shabl 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-6
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-7
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-8 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-9 
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

DEFINE VARIABLE ass-num-days-igt AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13.38 BY 1 NO-UNDO.

DEFINE VARIABLE ass-proc-matr-shabl AS INTEGER FORMAT ">>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6.5 BY 1 NO-UNDO.

DEFINE VARIABLE ass-srokiztdel AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13.38 BY 1 NO-UNDO.

DEFINE VARIABLE crit-srokgod AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13.38 BY 1 NO-UNDO.

DEFINE VARIABLE v-Ass-Num-days-igt AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 78 BY 1 NO-UNDO.

DEFINE VARIABLE v-Ass-proc-matr-shabl AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 77.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-ass-srokiztdel AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 78 BY 1 NO-UNDO.

DEFINE VARIABLE v-crit-srokgod AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 78 BY 1 NO-UNDO.

DEFINE IMAGE I-ass-num-days-igt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.

DEFINE IMAGE I-ass-proc-matr-shabl
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.

DEFINE IMAGE I-ass-srokiztdel
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.

DEFINE IMAGE I-crit-srokgod
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 88
     B-6 AT ROW 2.25 COL 3.63 WIDGET-ID 90
     ass-srokiztdel AT ROW 2.25 COL 4.63 COLON-ALIGNED NO-LABEL WIDGET-ID 190
     crit-srokgod AT ROW 3.25 COL 4.5 COLON-ALIGNED NO-LABEL WIDGET-ID 192
     B-7 AT ROW 3.29 COL 3.63 WIDGET-ID 194
     B-8 AT ROW 4.25 COL 3.5 WIDGET-ID 202
     ass-num-days-igt AT ROW 4.25 COL 4.5 COLON-ALIGNED NO-LABEL WIDGET-ID 204
     B-9 AT ROW 5.25 COL 3.5 WIDGET-ID 210
     ass-proc-matr-shabl AT ROW 5.25 COL 4.5 COLON-ALIGNED NO-LABEL WIDGET-ID 208
     v-ass-srokiztdel AT ROW 2.25 COL 20 NO-LABEL WIDGET-ID 78
     v-crit-srokgod AT ROW 3.29 COL 20 NO-LABEL WIDGET-ID 198
     v-Ass-Num-days-igt AT ROW 4.25 COL 20 NO-LABEL WIDGET-ID 206
     v-Ass-proc-matr-shabl AT ROW 5.25 COL 20.5 NO-LABEL WIDGET-ID 214
     I-ass-srokiztdel AT ROW 2.25 COL 1 WIDGET-ID 72
     I-crit-srokgod AT ROW 3.29 COL 1 WIDGET-ID 196
     I-ass-num-days-igt AT ROW 4.25 COL 1 WIDGET-ID 200
     I-ass-proc-matr-shabl AT ROW 5.25 COL 1 WIDGET-ID 212
     SPACE(94.74) SKIP(15.96)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки Ассортиментной политики"
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

/* SETTINGS FOR FILL-IN v-Ass-Num-days-igt IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-Ass-Num-days-igt:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-Ass-proc-matr-shabl IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       v-Ass-proc-matr-shabl:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-ass-srokiztdel IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       v-ass-srokiztdel:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-crit-srokgod IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       v-crit-srokgod:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Настройки Ассортиментной политики */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки Ассортиментной политики */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-6 Dialog-Frame
ON CHOOSE OF B-6 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-ass-obj},
       "ass-srokiztdel"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-7 Dialog-Frame
ON CHOOSE OF B-7 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-ass-obj},
       "crit-srokgod"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-8
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-8 Dialog-Frame
ON CHOOSE OF B-8 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-ass-obj},
       "ass-num-days-igt"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-9
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-9 Dialog-Frame
ON CHOOSE OF B-9 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-ass-obj},
       "ass-proc-matr-shabl"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ass-num-days-igt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ass-num-days-igt Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ass-num-days-igt IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ass-proc-matr-shabl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ass-proc-matr-shabl Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ass-proc-matr-shabl IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-ass-srokiztdel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-ass-srokiztdel Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-ass-srokiztdel IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-crit-srokgod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-crit-srokgod Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-crit-srokgod IN FRAME Dialog-Frame
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
    'actn_nakl-par_lookup':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
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
  DISPLAY ass-srokiztdel crit-srokgod ass-num-days-igt ass-proc-matr-shabl 
         v-ass-srokiztdel v-crit-srokgod v-Ass-Num-days-igt 
          v-Ass-proc-matr-shabl 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit I-ass-srokiztdel I-crit-srokgod I-ass-num-days-igt 
         I-ass-proc-matr-shabl B-quit B-Help B-6 ass-srokiztdel crit-srokgod 
         B-7 B-8 ass-num-days-igt B-9 ass-proc-matr-shabl v-ass-srokiztdel 
         v-crit-srokgod v-Ass-Num-days-igt v-Ass-proc-matr-shabl 
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
for each thbjattr_thbj-attr-g:
  delete thbjattr_thbj-attr-g.
end.


for each temp-thbj-attr:
  delete temp-thbj-attr.
end.

run adm/shattri.p (
    input "init":U
  , input p-obj-type
  , input p-obj-code
  , input {&attr-ass-obj}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.

&scop telo1  IF thbjattr_thbj-attr.prop-code = ~{&attr-ass-obj_~{&pole~}~} THEN DO: ~
    ~{&pole~} = thbjattr_thbj-attr.property-value-~{&type~}. ~
    ~{&pole~}:private-data in frame {&frame-name} = "recid2=" + string(recid(thbjattr_thbj-attr)). ~
    display ~{&pole~} with frame {&frame-name} . ~
END.

&scop telo1g  IF thbjattr_thbj-attr-g.prop-code = ~{&attr-ass-global_~{&pole~}~} THEN DO: ~
    ~{&pole~} = thbjattr_thbj-attr-g.property-value-~{&type~}. ~
    ~{&pole~}:private-data in frame {&frame-name} = "recid3=" + string(recid(thbjattr_thbj-attr-g)). ~
    display ~{&pole~} with frame {&frame-name} . ~
END.


FOR EACH thbjattr_thbj-attr
:

&scop pole ass-srokiztdel
&scop type integer
{&telo1}

&scop pole crit-srokgod
&scop type integer
{&telo1}

&scop pole ass-num-days-igt
&scop type integer
{&telo1}


&scop pole ass-proc-matr-shabl
&scop type integer
{&telo1}


  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.

END.


define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .

&scop telo2 run thbjattr_tooltip in this-procedure ( ~
   input   {&attr-ass-obj} ~
  ,input  "~{&pole~}" ~
  ,output v-tooltip ~
  ,output v-label ~
  ,output v-tooltip-code ~
  ) no-error . ~
v-~{&pole~}:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  ~
I-~{&pole~}:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .

&scop telo2g run thbjattr_tooltip in this-procedure ( ~
   input   {&attr-ass-global} ~
  ,input  "~{&pole~}" ~
  ,output v-tooltip ~
  ,output v-label ~
  ,output v-tooltip-code ~
  ) no-error . ~
v-~{&pole~}:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  ~
I-~{&pole~}:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .

&scop pole ass-srokiztdel
{&telo2}

&scop pole crit-srokgod
{&telo2}

&scop pole ass-num-days-igt
{&telo2}

&scop pole ass-proc-matr-shabl
{&telo2}


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
    find first obj_thbj-attr exclusive-lock where
              obj_thbj-attr.obj-type = p-obj-type
        and   obj_thbj-attr.obj-code = p-obj-code
        and   obj_thbj-attr.upper-prop-code = {&attr-ass-obj}
        and   obj_thbj-attr.prop-code = '':u no-wait no-error.
     if locked obj_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-ass-obj} skip
        "Запись ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
  end.
  else do:
    find first obj_thbj-attr no-lock where
          obj_thbj-attr.obj-type = p-obj-type
    and   obj_thbj-attr.obj-code = p-obj-code
    and   obj_thbj-attr.upper-prop-code = {&attr-ass-obj}
    and   obj_thbj-attr.prop-code = '':u no-error.
  end.
  if not available obj_thbj-attr then do:
    assign
      v-to-create-trn  = true
      .
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
                 view-as alert-box warning.

  end.
  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> {&update} then do:
     disable
     ass-srokiztdel
     crit-srokgod
     ass-num-days-igt
     ass-proc-matr-shabl
     with frame {&frame-name}.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame {&frame-name} .
  END.
  if not ( p-obj-type = "" and p-obj-code = 0 ) then do:
     disable
     with frame {&frame-name}.
  end.
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
define variable v-sameg as logical no-undo .
IF p-mode = {&LOOKUP} THEN RETURN .
define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_nakl-par_update':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return error. end.

ASSIGN
    FRAME {&FRAME-NAME}
    ass-srokiztdel
    crit-srokgod
    ass-num-days-igt
 .
assign
  fh = frame {&frame-name}:first-child
  wh = fh:first-child
  .
do while valid-handle(wh):
  if wh:private-data begins "recid2=" then do:

    find first thbjattr_thbj-attr where
               recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '='))
               no-error .
    if available thbjattr_thbj-attr then do:
    assign
    buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
           thbjattr_thbj-attr.obj-type = p-obj-type.
           thbjattr_thbj-attr.obj-code = p-obj-code.
    end.
  end.
/*
  if wh:private-data begins "recid3=" then do:

    find first thbjattr_thbj-attr-g where
               recid(thbjattr_thbj-attr-g) = integer(entry(2, wh:private-data, '='))
               no-error .
    if available thbjattr_thbj-attr-g then do:
    assign
    buffer thbjattr_thbj-attr-g:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.
  */
  wh = wh:next-sibling.
end.
v-same = yes.
for each thbjattr_thbj-attr where
         thbjattr_thbj-attr.obj-type = p-obj-type and
         thbjattr_thbj-attr.obj-code = p-obj-code ,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = p-obj-type
      and temp-thbj-attr.obj-code = p-obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code :
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.

v-same = no.
v-sameg = yes.


do transaction
on error undo, return error return-value
:

  run thbjattr_set-section in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input {&attr-ass-obj}
      , input table thbjattr_thbj-attr
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.
  if p-obj-type = "" and p-obj-code = 0  then do:
  end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

