&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экран редактирования объектов в экране продавца

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/

/* ***************************  Definitions  ************************** */
{ cmp/str-glbl.i }
{ str/stockscr.i }
{ cmp/showinf.i }
/* Parameters Definitions ---                                           */
define input parameter paruser-name as character no-undo.
define output parameter par-chg as logical no-undo.
/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-usrstko

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 tt-usrstko.obj-type tt-usrstko.obj-code tt-usrstko.obj-name tt-usrstko.main-obj-type tt-usrstko.main-obj-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH tt-usrstko use-index level indexed-reposition
&Scoped-define OPEN-QUERY-BROWSE-1 oPEN QUERY {&SELF-NAME} FOR EACH tt-usrstko use-index level indexed-reposition.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 tt-usrstko
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 tt-usrstko


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-add b-del b-chg b-help BROWSE-1 ~
b-up b-down

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-down
     IMAGE-UP FILE "adeicon\vcrfwd":U
     IMAGE-DOWN FILE "adeicon\vcrfwd":U
     IMAGE-INSENSITIVE FILE "adeicon\vcrfwd":U
     LABEL ""
     SIZE 3.75 BY 1.58.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-up
     IMAGE-UP FILE "adeicon\vcrrew":U
     IMAGE-DOWN FILE "adeicon\vcrrew":U
     IMAGE-INSENSITIVE FILE "adeicon\vcrrew":U
     LABEL ""
     SIZE 3.75 BY 1.58.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      tt-usrstko SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      tt-usrstko.obj-type column-label "Тип"
tt-usrstko.obj-code column-label "Код объекта"
tt-usrstko.obj-name format "x(10)" column-label "Название"
tt-usrstko.main-obj-type column-label "Тип"
tt-usrstko.main-obj-code column-label "Код гл. объекта"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 48.25 BY 9.92.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.08 COL 1.5
     b-add AT ROW 1.08 COL 12
     b-del AT ROW 1.08 COL 22.5
     b-chg AT ROW 1.08 COL 33
     b-help AT ROW 1.08 COL 43.5
     BROWSE-1 AT ROW 2.33 COL 1
     b-up AT ROW 2.42 COL 49.75
     b-down AT ROW 4.04 COL 49.75
     SPACE(0.00) SKIP(6.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройка объектов для пользователя"
         DEFAULT-BUTTON b-exit.


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
/* BROWSE-TAB BROWSE-1 b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
oPEN QUERY {&SELF-NAME} FOR EACH tt-usrstko use-index level indexed-reposition.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройка объектов для пользавателя */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable varadd as logical no-undo.
  define variable varobj-type like ub.clients.obj-type no-undo.
  define variable varobj-code like ub.clients.obj-code no-undo.
  run str/stkscrao.w (input  paruser-name,
                  input  {&add-def},
                  output varadd,
                  input-output varobj-type,
                  input-output varobj-code,
                  input-output table tt-usrstko) no-error.

  if error-status:error then do:
    message "Ошибка при добавлении объекта." view-as alert-box.
    return no-apply.
  end.
  if varadd = yes then do:
    {&open-query-browse-1}
    find first tt-usrstko where tt-usrstko.user-name = paruser-name and
                                             tt-usrstko.obj-type = varobj-type and
                                             tt-usrstko.obj-code = varobj-code .
    reposition {&browse-name} to recid recid(tt-usrstko).
  end.
  assign par-chg = yes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable varrec-id as recid no-undo.
  define variable varobj-type like ub.clients.obj-type no-undo.
  define variable varobj-code like ub.clients.obj-code no-undo.
  define variable varchg      as   logical no-undo.
  define buffer bf_tt-usrstko for tt-usrstko.
  if available tt-usrstko then do:
    assign
      varobj-type = tt-usrstko.obj-type
      varobj-code = tt-usrstko.obj-code.
    find first bf_tt-usrstko where recid(bf_tt-usrstko) = recid(tt-usrstko).
    run str/stkscrao.w (input paruser-name,
                    input {&update},
                    output varchg,
                    input-output bf_tt-usrstko.obj-type,
                    input-output bf_tt-usrstko.obj-code,
                    input-output table tt-usrstko) no-error.
    {&open-query-browse-1}
    find first bf_tt-usrstko where bf_tt-usrstko.obj-type = varobj-type and
                                   bf_tt-usrstko.obj-code = varobj-code .
    reposition {&browse-name} to recid recid(bf_tt-usrstko).
    assign par-chg = yes.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define buffer bf_tt-usrstko for tt-usrstko.
  define buffer bf_usr-flt    for ubflt.usr-flt.
  define buffer bfu_usr-flt   for ubflt.usr-flt.
  define variable varrec-id as recid no-undo.
  if available tt-usrstko then do:
    find first bf_tt-usrstko where bf_tt-usrstko.main-obj-type  = tt-usrstko.obj-type and
                                              bf_tt-usrstko.main-obj-code = tt-usrstko.obj-code no-error.
    if available bf_tt-usrstko then do:
      message "Данный объект является главным для объекта " bf_tt-usrstko.obj-type " " bf_tt-usrstko.obj-code " ."
      view-as alert-box error.
      return no-apply.
     end.
     for each bf_usr-flt where bf_usr-flt.user-name  = paruser-name and
                               bf_usr-flt.call-point begins  "stockscr" no-lock :
        if tt-usrstko.obj-type  = substring(bf_usr-flt.call-point, 9, 3) and
           tt-usrstko.obj-code  = integer(substring(bf_usr-flt.call-point, 12)) then do:
           find first bfu_usr-flt where recid(bfu_usr-flt) = recid(bf_usr-flt) exclusive-lock.
           delete bfu_usr-flt.
           leave.
        end.
     end.
     delete tt-usrstko.
     if {&browse-name}:delete-current-row() then.
     assign par-chg = yes.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-down Dialog-Frame
ON CHOOSE OF b-down IN FRAME Dialog-Frame
DO:
define buffer bf_tt-usrstko for tt-usrstko.
define variable varlevel like tt-usrstko.level no-undo.
define buffer bf_usr-flt for ubflt.usr-flt.
define buffer bfu_usr-flt for ubflt.usr-flt.
define variable varrec-id as recid no-undo.
if available tt-usrstko then do:
  find first bf_tt-usrstko where recid(bf_tt-usrstko) = recid(tt-usrstko) no-error.
  find next bf_tt-usrstko where bf_tt-usrstko.user-name = tt-usrstko.user-name use-index level  no-error.
  if not available bf_tt-usrstko then do:
    message "Данный объект имеет самый низкий уровень." view-as alert-box.
    return no-apply.
  end.
  assign
    varlevel = bf_tt-usrstko.level
    bf_tt-usrstko.level = tt-usrstko.level
    tt-usrstko.level = varlevel.
  for each bf_usr-flt where bf_usr-flt.user-name  = paruser-name and
                            bf_usr-flt.call-point begins  "stockscr"  no-lock :
    if tt-usrstko.obj-type  = substring(bf_usr-flt.call-point, 9, 3) and
       tt-usrstko.obj-code  = integer(substring(bf_usr-flt.call-point, 12)) then do:
      find first bfu_usr-flt where recid(bfu_usr-flt) = recid(bf_usr-flt) exclusive-lock.
      assign bfu_usr-flt.naim = string(tt-usrstko.level).
    end.
    if bf_tt-usrstko.obj-type  = substring(bf_usr-flt.call-point, 9, 3) and
       bf_tt-usrstko.obj-code  = integer(substring(bf_usr-flt.call-point, 12)) then do:
      find first bfu_usr-flt where recid(bfu_usr-flt) = recid(bf_usr-flt) exclusive-lock.
      assign bfu_usr-flt.naim = string (bf_tt-usrstko.level).
    end.
  end.
  assign varrec-id = recid(tt-usrstko).
  {&open-query-browse-1}
  reposition {&browse-name} to recid varrec-id.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-up Dialog-Frame
ON CHOOSE OF b-up IN FRAME Dialog-Frame
DO:

  define buffer bf_tt-usrstko for tt-usrstko.
  define variable varlevel like tt-usrstko.level no-undo.
  define buffer bf_usr-flt  for ubflt.usr-flt.
  define buffer bfu_usr-flt for ubflt.usr-flt.
  define variable varrec-id as recid no-undo.
  if available tt-usrstko then do:
    find first bf_tt-usrstko where recid(bf_tt-usrstko) = recid(tt-usrstko) no-error.
    find prev bf_tt-usrstko where bf_tt-usrstko.user-name = tt-usrstko.user-name use-index level no-error.
    if not available bf_tt-usrstko then do:
      message "Данный объект имеет самый высокий уровень." view-as alert-box.
      return no-apply.
    end.
    assign
      varlevel = bf_tt-usrstko.level
      bf_tt-usrstko.level = tt-usrstko.level
      tt-usrstko.level = varlevel.
    for each bf_usr-flt where bf_usr-flt.user-name  = paruser-name and
                              bf_usr-flt.call-point begins "stockscr"   no-lock :
      if tt-usrstko.obj-type  = substring(bf_usr-flt.call-point, 9, 3) and
         tt-usrstko.obj-code  = integer(substring(bf_usr-flt.call-point, 12)) then do:
        find first bfu_usr-flt where recid(bfu_usr-flt) = recid(bf_usr-flt) exclusive-lock.
        assign bfu_usr-flt.naim = string (tt-usrstko.level).
      end.
      if bf_tt-usrstko.obj-type  = substring(bf_usr-flt.call-point, 9, 3) and
         bf_tt-usrstko.obj-code  = integer(substring(bf_usr-flt.call-point, 12)) then do:
        find first bfu_usr-flt where recid(bfu_usr-flt) = recid(bf_usr-flt) exclusive-lock.
        assign bfu_usr-flt.naim = string (bf_tt-usrstko.level).
     end.
    end.
    assign varrec-id = recid(tt-usrstko).
    {&open-query-browse-1}
    reposition {&browse-name} to recid varrec-id.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
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
  run loadusr-tt (input paruser-name) no-error.
    if error-status:error then do:
      message "Ошибка при загрузке настроек клиента." skip
              return-value skip
              error-status:get-message(1) view-as alert-box.
      return error.
    end.
  RUN enable_UI.
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
  ENABLE b-exit b-add b-del b-chg b-help BROWSE-1 b-up b-down
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME