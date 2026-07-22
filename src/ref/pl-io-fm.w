&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Создание и изменение мест приемки/отгрузки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/18/09
Author: Dmitry Ukhanov
Creation date: 02/18/09

Автор1: Кочетков Михаил Юрьевич
Дата создания1: 05/10/06

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-mode        as character no-undo.
define input-output parameter p-rep-rec     as recid no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "создание и изменение мест приемки/отгрузки".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ cmp/library.i }

define buffer buf_place-io for ub.place-io .

define variable p-sys-time as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save b-quit B-hist b-help RADIO-type v-num ~
v-name v-PS
&Scoped-Define DISPLAYED-OBJECTS RADIO-type v-num v-name v-PS

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.

DEFINE VARIABLE v-name AS CHARACTER FORMAT "X(40)"
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 51 BY 1.

DEFINE VARIABLE v-num AS INTEGER FORMAT ">>>>>>>>>9" INITIAL 0
     LABEL "Номер"
     VIEW-AS FILL-IN
     SIZE 19.5 BY 1.

DEFINE VARIABLE v-PS AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 62.5 BY 6.25 NO-UNDO.

DEFINE VARIABLE RADIO-type AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "приемки", 1,
"отгрузки", 2
     SIZE 26.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 41
     b-help AT ROW 1 COL 55.13
     RADIO-type AT ROW 2.5 COL 3 NO-LABEL
     v-num AT ROW 2.5 COL 42.5 COLON-ALIGNED
     v-name AT ROW 3.71 COL 11 COLON-ALIGNED
     v-PS AT ROW 5.92 COL 2 NO-LABEL
     "Примечание:" VIEW-AS TEXT
          SIZE 15 BY .67 AT ROW 5.08 COL 3
     SPACE(47.12) SKIP(6.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Место приемки/отгрузки".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       v-num:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-PS IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Место приемки/отгрузки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  if not available buf_place-io then return .
  run ref/pliohist.w ( INPUT parParentProc
                     , input buf_place-io.obj-type
                     , input buf_place-io.obj-code
                     , input buf_place-io.place-io-code
                     , input "":U /*bttns  */
                     , input-output v-rid-list
                     ) no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
p-rep-rec = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Ввод */
DO:
  assign RADIO-type v-name v-PS .
  if v-name = "" or v-name = ? then do:
    message "Название места должно быть заполнено.".
    apply "entry" to v-name in frame {&frame-name}.
    return no-apply.
  end.

  if p-mode = {&add-def} then do:
    create buf_place-io .
    if can-find( ub.place-io no-lock where ub.place-io.place-io-code = v-num and ub.place-io.obj-type = p-obj-type and ub.place-io.obj-code = p-obj-code ) then do:
      run gen_code(input-output v-num ) no-error.
      if error-status:error then undo, return .
    end.
    assign
      buf_place-io.place-io-code = v-num
      buf_place-io.obj-type      = p-obj-type
      buf_place-io.obj-code      = p-obj-code
      buf_place-io.status_       = {&g___new}
    .
  end.
  assign
    buf_place-io.place-io-name = v-name
    buf_place-io.PS            = v-PS
  .
  if RADIO-type = 1 then assign buf_place-io.place-io-type = {&place-in} .
  else                   assign buf_place-io.place-io-type = {&place-out} .

  p-rep-rec = recid (buf_place-io).
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

  if p-mode = {&update} then do:
    find buf_place-io where recid (buf_place-io) = p-rep-rec.
    assign
      v-num  = buf_place-io.place-io-code
      v-name = buf_place-io.place-io-name
      v-PS   = buf_place-io.PS
    .
    if buf_place-io.place-io-type = {&place-in} then assign RADIO-type = 1 .
    else                                             assign RADIO-type = 2 .
  end.
  else  run gen_code( input-output v-num ) no-error.

  frame {&frame-name}:title = "Место приемки/отгрузки на объекте : " + p-obj-type + " " + string (p-obj-code) + "         " + p-mode.

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
  DISPLAY RADIO-type v-num v-name v-PS WITH FRAME Dialog-Frame.
  ENABLE b-save b-quit B-hist b-help RADIO-type v-num v-name v-PS WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gen_code Dialog-Frame
PROCEDURE gen_code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  DEFINE INPUT-OUTPUT PARAMETER loc-f-code as integer no-undo.
  def var my-value as integer no-undo.
gen-code:
  do while true:
    my-value = next-value( s-place-io, {&db-name_schema} ).
    if my-value >= 99999999 or my-value = ? then do:
      current-value(s-place-io, {&db-name_schema}) = 1.
      next.
    end.
    if not can-find( ub.place-io no-lock where ub.place-io.place-io-code = my-value and ub.place-io.obj-type = p-obj-type and ub.place-io.obj-code = p-obj-code ) then leave gen-code.
  end.
  assign loc-f-code = my-value .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME