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

Экран добавления объекта для экрана продавца

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

{ cmp/str-glbl.i }
{ str/stockscr.i }
define input parameter paruser-name as character no-undo.
define input parameter parmode as character no-undo.
define output parameter paradd as logical no-undo.
define input-output parameter parobj-type like ub.clients.obj-type no-undo.
define input-output parameter parobj-code like ub.clients.obj-code no-undo.
define input-output parameter table for tt-usrstko.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран добавления объекта для экрана продавца".
{ cmp/vssrevis.i }
{ cmp/showinf.i }


/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save b-cancel b-help b-obj ~
varmain-obj-code varmain-obj-type b-mobj
&Scoped-Define DISPLAYED-OBJECTS varobj-code varobj-type varmain-obj-code ~
varmain-obj-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mobj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-mobj"
     SIZE 3 BY .88.

DEFINE BUTTON b-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-obj"
     SIZE 3 BY .88.

DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE varmain-obj-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL ?
     LABEL "Гл. объект"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE varmain-obj-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE varobj-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 10.13 BY 1 NO-UNDO.

DEFINE VARIABLE varobj-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1.08 COL 1.63
     b-cancel AT ROW 1.08 COL 12.13
     b-help AT ROW 1.08 COL 22.5
     varobj-code AT ROW 2.5 COL 12 COLON-ALIGNED
     varobj-type AT ROW 2.5 COL 25.25 NO-LABEL
     b-obj AT ROW 2.63 COL 29.5
          varmain-obj-code AT ROW 3.67 COL 12 COLON-ALIGNED
     varmain-obj-type AT ROW 3.67 COL 25.25 NO-LABEL
     b-mobj AT ROW 3.75 COL 29.63
     SPACE(0.36) SKIP(0.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Объект в экране остатков"
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
   Custom                                                               */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN varmain-obj-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN varobj-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varobj-type IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Объект в экране остатков */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mobj Dialog-Frame
ON CHOOSE OF b-mobj IN FRAME Dialog-Frame /* b-mobj */
DO:
    run str/chshobj.w (input ?,
                   input varmain-obj-type,
                   input varmain-obj-code,
                   output varmain-obj-type,
                   output varmain-obj-code).
   display varmain-obj-type varmain-obj-code with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-obj Dialog-Frame
ON CHOOSE OF b-obj IN FRAME Dialog-Frame /* b-obj */
DO:
  run str/chshobj.w (input ?,
                 input varobj-type,
                 input varobj-code,
                 output varobj-type,
                 output varobj-code).
   display varobj-type varobj-code with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Сохранить */
DO:
define buffer bf_tt-usrstko   for tt-usrstko.
define buffer bf_clients      for ub.clients.
define buffer bf-main_clients for ub.clients.
define buffer bf_usr-flt      for ubflt.usr-flt.
  if parmode = {&add-def} then do:
    run chk-obj in this-procedure no-error.
    if error-status:error then do:
      message "Ошибка при проверке объекта." view-as alert-box.
      return no-apply.
    end.
  end.
  run chk-main-obj in this-procedure ( input parmode )no-error.
  if error-status:error then do:
    message "Ошибка при проверке главного объекта." view-as alert-box.
    return no-apply.
  end.
  if parmode = {&add-def} then do:
    create tt-usrstko.
    assign
      tt-usrstko.user-name = paruser-name.
    find last bf_tt-usrstko where bf_tt-usrstko.user-name = paruser-name use-index level no-error.
    if available bf_tt-usrstko then do:
      assign
        tt-usrstko.level = bf_tt-usrstko.level + 1.
     end.
     else do:
       assign tt-usrstko.level = 1.
     end.
     find first bf_clients where bf_clients.obj-type = varobj-type and
                                 bf_clients.obj-code = varobj-code no-lock.
     assign
      tt-usrstko.user-name     = paruser-name
      tt-usrstko.obj-type      = varobj-type
      tt-usrstko.obj-code      = varobj-code
      tt-usrstko.obj-name      = bf_clients.obj-name.
     create bf_usr-flt.
     assign
       bf_usr-flt.user-name  = paruser-name
       bf_usr-flt.call-point = "stockscr" + tt-usrstko.obj-type + string(tt-usrstko.obj-code)
       bf_usr-flt.naim       = string(tt-usrstko.level).
   end.
   else do:
     find first tt-usrstko where tt-usrstko.user-name = paruser-name and
                                 tt-usrstko.obj-type  = varobj-type  and
                                 tt-usrstko.obj-code  = varobj-code  .
     find first bf_usr-flt where bf_usr-flt.user-name  = paruser-name and
                                 bf_usr-flt.call-point = "stockscr" + tt-usrstko.obj-type + string(tt-usrstko.obj-code).

   end.

   if varmain-obj-code <> ? then do:
     find first bf-main_clients where bf-main_clients.obj-type = varmain-obj-type and
                                      bf-main_clients.obj-code = varmain-obj-code no-lock.
   end.
   assign
     tt-usrstko.main-obj-type = varmain-obj-type
     tt-usrstko.main-obj-code = varmain-obj-code
     tt-usrstko.main-obj-name = (if varmain-obj-code <> ? then bf-main_clients.obj-name else "")
     paradd                   = yes
     parobj-type              = tt-usrstko.obj-type
     parobj-code              = tt-usrstko.obj-code.
     bf_usr-flt.list_         = tt-usrstko.main-obj-type         + string(tt-usrstko.main-obj-code).
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
  if parmode = {&update}   then do:
    find first tt-usrstko where tt-usrstko.user-name = paruser-name and
                                tt-usrstko.obj-type = parobj-type and
                                tt-usrstko.obj-code = parobj-code.
    assign
       varobj-type      = tt-usrstko.obj-type
       varobj-code      = tt-usrstko.obj-code
       varmain-obj-type = tt-usrstko.main-obj-type
       varmain-obj-code = tt-usrstko.main-obj-code.
  end.
  RUN enable_UI.
  if parmode = {&add-def} then do:
    enable varobj-type varobj-code with frame {&frame-name}.
  end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-main-obj Dialog-Frame
PROCEDURE chk-main-obj :
define input parameter parmode as character no-undo .
define buffer bf_clients for ub.clients.
define buffer bf_tt-usrstko for tt-usrstko.
assign frame {&frame-name} varmain-obj-type varmain-obj-code.
if varmain-obj-type = varobj-type and
   varmain-obj-code = varobj-code then do:
  message "Главный объект равен текущему. " view-as alert-box error.
  return error.
end.

if varmain-obj-type <> "" or
   varmain-obj-code <> ? then do:
  find first bf_clients where bf_clients.obj-type = varmain-obj-type and
                                       bf_clients.obj-code = varmain-obj-code no-lock no-error.
  if not available bf_clients then do:
    message "Нет такого главного объекта: " varmain-obj-type " " varmain-obj-code " ." view-as alert-box.
    return error.
  end.
  if varmain-obj-type <> {&shop}  and
     varmain-obj-type <> {&stock} then do:
     message "Неверно задан тип главного объекта. Объект должен быть складом или магазином." view-as alert-box.
     return error.
  end.
  if parmode <> {&add-def} then do:
    find first bf_tt-usrstko where bf_tt-usrstko.user-name = paruser-name and
                                  bf_tt-usrstko.obj-type = varmain-obj-type and
                                  bf_tt-usrstko.obj-code = varmain-obj-code no-error.
    if not available bf_tt-usrstko then do:
      message "Нет записи о главном объекте в настройках данного пользователя. Сначала надо добавить главный объект."
      view-as alert-box.
      return error.
    end.
    if bf_tt-usrstko.main-obj-code <> ? then do:
      message "Нельзя выбирать главный объект который сам является подчиненным." view-as alert-box.
      return error.
    end.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-obj Dialog-Frame
PROCEDURE chk-obj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer bf_clients for ub.clients.
assign frame {&frame-name} varobj-type varobj-code.
find first bf_clients where bf_clients.obj-type = varobj-type and
                            bf_clients.obj-code = varobj-code no-lock no-error.
if not available bf_clients then do:
  message "Нет такого объекта: " varobj-type " " varobj-code " ." view-as alert-box.
  return error.
end.
find first tt-usrstko where tt-usrstko.obj-type = varobj-type and
                            tt-usrstko.obj-code = varobj-code no-error.
if available tt-usrstko then do:
  message "У Вас уже есть настроеный объект " varobj-type " " varobj-code view-as alert-box error.
  return error.
end.
if varobj-type <> {&shop}  and
   varobj-type <> {&stock} then do:
   message "Неверно задан тип объекта. Объект должен быть складом или магазином." view-as alert-box.
   return error.
end.

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
  DISPLAY varobj-code varobj-type varmain-obj-code varmain-obj-type
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help b-obj varmain-obj-code varmain-obj-type b-mobj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME