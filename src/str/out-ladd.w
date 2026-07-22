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

Экран просмотра дополнительной информации по расходу топлива

Автор: Уханов Дмитрий Юрьевич
Дата создания: 07/23/07
Author: Dmitry Ukhanov
Creation date: 07/23/07

Автор1: Суслов Алексей Юрьевич
Дата создания: 09/12/05
Author: Alexey Suslov
Creation date: 09/12/05

*/
/* Parameters Definitions ---                                           */
define input parameter parparentproc as handle no-undo.
define input parameter parmode       as char no-undo.
define input-output parameter parcar-num          as character no-undo.
define input-output parameter parautoent-obj-type as character no-undo.
define input-output parameter parautoent-obj-code as character no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран просмотра дополнительной информации по расходу топлива".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }

/* Local Variable Definitions ---                                       */

define variable varlog as logical no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save b-cancel B-help varautoent-obj-code ~
varautoent-obj-type b-clients varcar-num b-auto-tank
&Scoped-Define DISPLAYED-OBJECTS varautoent-obj-code varautoent-obj-type ~
varautoent-obj-name varcar-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-auto-tank
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-clients
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-clients"
     SIZE 3 BY .88.

DEFINE BUTTON B-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-save AUTO-GO
     LABEL "&Сохранить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE varautoent-obj-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Автопредприятие"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE varautoent-obj-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 43.88 BY 1.04 NO-UNDO.

DEFINE VARIABLE varautoent-obj-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE varcar-num AS CHARACTER FORMAT "X(256)":U
     LABEL "Гос. N автоцистерны"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1.13 COL 1.88
     b-cancel AT ROW 1.13 COL 12.38
     B-help AT ROW 1.13 COL 22.88
     varautoent-obj-code AT ROW 2.46 COL 16 COLON-ALIGNED
     varautoent-obj-type AT ROW 2.46 COL 27.75 COLON-ALIGNED NO-LABEL
     varautoent-obj-name AT ROW 2.46 COL 36 COLON-ALIGNED NO-LABEL
     b-clients AT ROW 2.58 COL 34.5
     varcar-num AT ROW 3.75 COL 20 COLON-ALIGNED
     b-auto-tank AT ROW 3.79 COL 36.38
     SPACE(42.49) SKIP(0.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дополнительная информация по приемке топлива"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.


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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN varautoent-obj-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Дополнительная информация по приемке топлива */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-auto-tank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-auto-tank Dialog-Frame
ON CHOOSE OF b-auto-tank IN FRAME Dialog-Frame
DO:
define variable varrec-tank as recid     no-undo.
define variable varrec-meas as recid     no-undo.
assign varrec-tank = ?
       varrec-meas = ?.
run str/auto-tn.w (input parparentproc,
               input "b-sel",
               input "",
               input 0,
               output varrec-tank,
               output varrec-meas) no-error.
if varrec-tank <> ? then do:
  find first auto-tank where recid (auto-tank) = varrec-tank no-lock.
  assign
      varcar-num = auto-tank.auto-num
  .
  display
      varcar-num
  with frame {&frame-name}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-clients
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-clients Dialog-Frame
ON CHOOSE OF b-clients IN FRAME Dialog-Frame /* b-clients */
DO:
define variable ref-list as character no-undo.
define variable ref-rec  as recid     no-undo.
   run ref/cli-all.w (parparentproc
                , "b-sel"
                , {&cmp}
                , ?
                , ?
                , ?
                , ?
                , ?
                , output ref-list) .
if ref-list <> "" then do:
  ref-rec = integer (ref-list).
  find clients where recid ( clients ) = ref-rec no-lock.
  disp clients.obj-code @ varautoent-obj-code
       clients.obj-type @ varautoent-obj-type
       clients.obj-name @ varautoent-obj-name with frame {&frame-name}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  { gbl/stdbtn.i }
  assign
  frame {&frame-name}
      varcar-num
      varautoent-obj-type
      varautoent-obj-code
  .
  find clients where clients.obj-type = varautoent-obj-type and
                     clients.obj-code = varautoent-obj-code no-lock no-error.
  if not available clients then do:
     varlog = no.
     message "Не найдено автопредприятие " varautoent-obj-type " " varautoent-obj-code " ." skip
             "Cохраняемся без ссылки на автопредприятие?"
     view-as alert-box question buttons yes-no update varlog.
     if varlog <> yes then return no-apply.
     assign
     varautoent-obj-type = ""
     varautoent-obj-code = ?.
  end.
  assign
      parcar-num          = varcar-num
      parautoent-obj-type = varautoent-obj-type
      parautoent-obj-code = string(varautoent-obj-code)
  no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varautoent-obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varautoent-obj-code Dialog-Frame
ON LEAVE OF varautoent-obj-code IN FRAME Dialog-Frame /* Автопредприятие */
DO:
  run disp-obj-name.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varautoent-obj-code Dialog-Frame
ON RETURN OF varautoent-obj-code IN FRAME Dialog-Frame /* Автопредприятие */
DO:
run disp-obj-name.
apply "entry" to varautoent-obj-code in frame {&frame-name}.
return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varautoent-obj-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varautoent-obj-type Dialog-Frame
ON LEAVE OF varautoent-obj-type IN FRAME Dialog-Frame
DO:
    run disp-obj-name.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varautoent-obj-type Dialog-Frame
ON return OF varautoent-obj-type IN FRAME Dialog-Frame
DO:
  run disp-obj-name.
  apply "entry" to varcar-num in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varcar-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varcar-num Dialog-Frame
ON return OF varcar-num IN FRAME Dialog-Frame /* Гос. N автоцистерны */
DO:
  apply "entry" to b-save in frame {&frame-name}.
return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
assign varcar-num = parcar-num.
assign varautoent-obj-type = parautoent-obj-type.
if varautoent-obj-type = "" then assign varautoent-obj-type = {&cmp}.
assign varautoent-obj-code = integer(parautoent-obj-code) no-error.
if error-status:error then
   message "Неверно указан код клиента " parautoent-obj-code " ."
   view-as alert-box error.
else do:
   find clients where clients.obj-type = varautoent-obj-type and
                      clients.obj-code = varautoent-obj-code no-lock no-error.
   if available clients then assign varautoent-obj-name = clients.obj-name.
   else assign varautoent-obj-name = ?.
end.
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  display
      varcar-num
      varautoent-obj-type
      varautoent-obj-code
      varautoent-obj-name
  with frame {&frame-name}.

  if parmode <> {&update} then
  disable
      varcar-num
      varautoent-obj-type
      varautoent-obj-code
  with frame {&frame-name}.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-obj-name Dialog-Frame
PROCEDURE disp-obj-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  find clients where clients.obj-code = input frame {&frame-name} varautoent-obj-code and
                     clients.obj-type = input frame {&frame-name} varautoent-obj-type no-lock no-error.
  if available clients then
  disp clients.obj-name @ varautoent-obj-name with frame {&frame-name}.
  else do:
      display ? @ varautoent-obj-name with frame {&frame-name}.
      apply "choose" to b-clients in frame {&frame-name}.
  end.

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
  DISPLAY varautoent-obj-code varautoent-obj-type varautoent-obj-name varcar-num
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel B-help varautoent-obj-code varautoent-obj-type
         b-clients varcar-num b-auto-tank
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
