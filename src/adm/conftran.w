&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

транспортные настройки

Автор: Кочетков Михаил Юрьевич
Дата создания: 05/30/06
Author: Michael Kochetkov
Creation date: 05/30/06

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input        parameter p-mode                as character no-undo .
define input        parameter p-type                as character no-undo . /* фирма или договор */
define input        parameter p-host-code           as integer   no-undo .
define input        parameter parParentProc         AS WIDGET-HANDLE NO-UNDO.
define input-output parameter p-transport-cli-type  like ub.sysconf.transport-cli-type   no-undo .
define input-output parameter p-transport-cli-code  like ub.sysconf.transport-cli-code   no-undo .
define input-output parameter p-transport-host      like ub.sysconf.transport-host       no-undo .
define input-output parameter p-transport-contract  like ub.sysconf.transport-contract   no-undo .
define input-output parameter p-transport-uslov     like ub.sysconf.transport-uslov      no-undo .
define input-output parameter p-transport-value     like ub.sysconf.transport-value      no-undo .
define input-output parameter p-transport-type      like ub.contract.transport-type      no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "транспортные настройки фирмы".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }

define buffer buf_delivery-type for ub.delivery-type .
define variable  agnt-list as character no-undo .
define variable v-transport-host as integer   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help transport-host cli-type ~
BUTTON-cli cli-name transport-contract BUTTON-contr FILL-cont ~
transport-value COMBO-usl transport-type BUTTON-type FILL-type
&Scoped-Define DISPLAYED-OBJECTS transport-host cli-type cli-name ~
transport-contract FILL-cont transport-value COMBO-usl transport-type ~
FILL-type

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

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.

DEFINE BUTTON BUTTON-contr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.

DEFINE BUTTON BUTTON-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.

DEFINE VARIABLE COMBO-usl AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 58.5 BY 1 NO-UNDO.

DEFINE VARIABLE cli-type AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 4.38 BY 1.

DEFINE VARIABLE cli-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 41.75 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-cont AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 41.75 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-type AS CHARACTER FORMAT "X(56)":U
     VIEW-AS FILL-IN
     SIZE 49.5 BY 1 NO-UNDO.

DEFINE VARIABLE transport-contract LIKE ub.sysconf.transport-contract
     LABEL "Транспортный договор"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE cli-code LIKE ub.sysconf.transport-cli-code
     LABEL "Контрагент"
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1 NO-UNDO.

DEFINE VARIABLE transport-type AS INTEGER FORMAT ">>>>9" INITIAL 0
     LABEL "Тип доставки"
     VIEW-AS FILL-IN
     SIZE 6.75 BY 1 NO-UNDO.

DEFINE VARIABLE transport-value LIKE ub.sysconf.transport-value
     LABEL "%"
     VIEW-AS FILL-IN
     SIZE 9.75 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 66.13
     cli-code AT ROW 2.5 COL 16.5 COLON-ALIGNED HELP
          ""
     cli-type AT ROW 2.5 COL 24.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     BUTTON-cli AT ROW 2.5 COL 31.13 WIDGET-ID 4
     cli-name AT ROW 2.5 COL 32.25 COLON-ALIGNED NO-LABEL
     transport-contract AT ROW 3.71 COL 21 COLON-ALIGNED HELP
          ""
          LABEL "Транспортный договор"
     BUTTON-contr AT ROW 3.71 COL 31.25 WIDGET-ID 2
     FILL-cont AT ROW 3.75 COL 32.25 COLON-ALIGNED NO-LABEL
     transport-value AT ROW 5.96 COL 64.25 COLON-ALIGNED HELP
          ""
          LABEL "%"
     COMBO-usl AT ROW 6.04 COL 1 COLON-ALIGNED NO-LABEL
     transport-type AT ROW 7.25 COL 13.75 COLON-ALIGNED
     BUTTON-type AT ROW 7.25 COL 23
     FILL-type AT ROW 7.25 COL 24.5 COLON-ALIGNED NO-LABEL
     "Условие предоставления транспортных услуг:" VIEW-AS TEXT
          SIZE 53 BY .67 AT ROW 5.21 COL 3
          FGCOLOR 4
     SPACE(20.62) SKIP(2.61)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Транспортные настройки фирмы".


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
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       cli-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       FILL-cont:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       FILL-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN transport-contract IN FRAME Dialog-Frame
   LIKE = ub.sysconf. EXP-LABEL EXP-SIZE                                */
/* SETTINGS FOR FILL-IN cli-code IN FRAME Dialog-Frame
   LIKE = ub.sysconf. EXP-SIZE                                          */
/* SETTINGS FOR FILL-IN transport-value IN FRAME Dialog-Frame
   LIKE = ub.sysconf. EXP-LABEL EXP-SIZE                                */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Транспортные настройки фирмы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  if p-mode <> {&lookup} then do:
    assign transport-value cli-code cli-type transport-contract COMBO-usl .
    case COMBO-usl :
      when {&transport-include-full} then assign p-transport-uslov = int({&transport-include}) .
      when {&transport-prc-full}     then
          assign
            p-transport-uslov = int({&transport-prc})
            p-transport-value = transport-value
          .
      when {&transport-dist-full}    then assign p-transport-uslov = int({&transport-dist}) .
    end.
    assign
      p-transport-cli-type = cli-type
      p-transport-cli-code = cli-code
      p-transport-host     = v-transport-host
      p-transport-contract = transport-contract
      p-transport-type     = transport-type
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-cli Dialog-Frame
ON CHOOSE OF BUTTON-cli IN FRAME Dialog-Frame /* 2 */
DO:
  assign
    transport-contract = 0
    v-transport-host   = 0
    FILL-cont          = ""
  .
  define buffer buf_clients for ub.clients.
  run ref/cli-all.w (parParentProc, "b-sel", {&all}, {&all}, {&current}, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
  if agnt-list <> "" then do:
    find first buf_clients no-lock where RECID(buf_clients) = int (agnt-list) no-error.
    if buf_clients.obj-type <> {&prs} and buf_clients.obj-type <> {&cmp} then do:
      message
        "Контрагент может быть только " {&cmp} " или " {&prs}
        view-as alert-box ERROR .
      return no-apply.
    end.
    assign
      cli-name = buf_clients.obj-name
      cli-code = buf_clients.obj-code
      cli-type = buf_clients.obj-type
    .
  end.
  else assign cli-name = ""  cli-code = ?  cli-type  = ? .
  display     cli-name       cli-code      cli-type transport-contract FILL-cont   with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-contr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-contr Dialog-Frame
ON CHOOSE OF BUTTON-contr IN FRAME Dialog-Frame /* 2 */
DO:
  define buffer buf_contract for ub.contract.
  run str/cont-all.w ( input  parParentProc, input p-host-code, input "b-sel":U, input {&company}, input cli-type, input cli-code, input  ?, input  ?, input  "current", input {&income} , input-output agnt-list   ) no-error .
  find first buf_contract no-lock where RECID(buf_contract) = int (agnt-list) no-error.
  if not available buf_contract then do:
    assign
      transport-contract = 0
      v-transport-host = 0
      FILL-cont = ""
    .
    display transport-contract FILL-cont  with frame {&frame-name}.
    return.
  end.
  assign
    transport-contract = buf_contract.contract-code
    v-transport-host   = buf_contract.host-code
    FILL-cont          = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")
  .
  display transport-contract FILL-cont  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-type Dialog-Frame
ON CHOOSE OF BUTTON-type IN FRAME Dialog-Frame /* 2 */
DO:
  define variable v-rid-list as character no-undo.
  define variable v-sts as integer no-undo .
  { gbl/stdbtn.i }

  if available buf_delivery-type then
    assign
      v-rid-list = string(recid(buf_delivery-type))
      v-sts = buf_delivery-type.sts
    .
  run ref/dlvtypes.w (input parParentProc, v-cntxt-obj-type, v-cntxt-obj-code, "b-sel":U, {&all}, input-output v-sts, input-output v-rid-list ) no-error .

  if v-rid-list <> "":U then do:
    FIND FIRST buf_delivery-type WHERE recid( buf_delivery-type ) = integer(entry(1, v-rid-list)) NO-LOCK .
    assign
      transport-type = buf_delivery-type.deliv-type-code
      FILL-type      = buf_delivery-type.deliv-type-name
    .
    display transport-type  FILL-type  with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-type Dialog-Frame
ON LEAVE OF cli-type IN FRAME Dialog-Frame
DO:
  assign cli-type.
  assign
    transport-contract = 0
    v-transport-host   = 0
    FILL-cont          = ""
  .
  define buffer buf_clients for ub.clients.
  if cli-type <> {&cmp} and cli-type <> {&prs} then do:
    find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = cli-code no-error.
    if not available buf_clients then do:
      find first buf_clients no-lock where buf_clients.obj-type = {&prs} and buf_clients.obj-code = cli-code no-error.
    end.
  end.
  else find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.

  if not available buf_clients then do:
    if cli-code = 0 then assign cli-code = ? .
    if cli-code = ? then do:
      assign cli-name = ""   cli-code = ?  cli-type  = ? .
      display cli-name    cli-code     cli-type    with frame {&frame-name}.
    end.
    else do:
      apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
    end.
    return.
  end.
  assign
    cli-name = buf_clients.obj-name
    cli-code = buf_clients.obj-code
    cli-type = buf_clients.obj-type
  .
  display cli-name    cli-code     cli-type  transport-contract FILL-cont   with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME COMBO-usl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL COMBO-usl Dialog-Frame
ON VALUE-CHANGED OF COMBO-usl IN FRAME Dialog-Frame
DO:
  assign COMBO-usl .
  if COMBO-usl:screen-value = {&transport-prc-full} then transport-value:visible = yes .
  else                                                   transport-value:visible = no .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME transport-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL transport-contract Dialog-Frame
ON LEAVE OF transport-contract IN FRAME Dialog-Frame /* Транспортный договор */
DO:
  if transport-contract = int ( transport-contract:screen-value ) then return.
  assign transport-contract .

  define buffer buf_contract for ub.contract .
  find first buf_contract no-lock
    where buf_contract.host-code     = p-host-code
      and buf_contract.contract-code = transport-contract
      and buf_contract.cli-code      = cli-code
      and buf_contract.cli-type      = cli-type
  no-error.
  if not available buf_contract then do:
    apply "CHOOSE" to BUTTON-contr IN FRAME Dialog-Frame .
  end.
  else do:
    assign
      transport-contract = buf_contract.contract-code
      v-transport-host   = buf_contract.host-code
      FILL-cont          = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")
    .
  end.
  display transport-contract FILL-cont  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL transport-contract Dialog-Frame
ON RETURN OF transport-contract IN FRAME Dialog-Frame /* Транспортный договор */
DO:
  if transport-contract = int ( transport-contract:screen-value ) then return.
  assign transport-contract .

  define buffer buf_contract for ub.contract .
  find first buf_contract no-lock
    where buf_contract.host-code     = p-host-code
      and buf_contract.contract-code = transport-contract
      and buf_contract.cli-code      = cli-code
      and buf_contract.cli-type      = cli-type
  no-error.
  if not available buf_contract then do:
    apply "CHOOSE" to BUTTON-contr IN FRAME Dialog-Frame .
  end.
  else do:
    assign
      transport-contract = buf_contract.contract-code
      v-transport-host   = buf_contract.host-code
      FILL-cont          = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")
    .
    display transport-contract FILL-cont  with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code Dialog-Frame
ON LEAVE OF cli-code IN FRAME Dialog-Frame /* Грузоперевозчик */
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code .
  DISABLE transport-contract WITH FRAME Dialog-Frame.
  assign
    transport-contract = 0
    v-transport-host   = 0
    FILL-cont          = ""
  .
  define buffer buf_clients for ub.clients.
  find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.
  if not available buf_clients then do:
    apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
  end.
  else do:
    assign
      cli-code           = buf_clients.obj-code
      cli-type           = buf_clients.obj-type
      cli-name           = buf_clients.obj-name
    .
  end.
  ENABLE transport-contract WITH FRAME Dialog-Frame.
  display cli-code cli-type cli-name  transport-contract FILL-cont  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code Dialog-Frame
ON RETURN OF cli-code IN FRAME Dialog-Frame /* Грузоперевозчик */
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code .
  DISABLE transport-contract WITH FRAME Dialog-Frame.
  assign
    transport-contract = 0
    v-transport-host   = 0
    FILL-cont          = ""
  .
  define buffer buf_clients for ub.clients.
  find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.
  if not available buf_clients then do:
    apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
  end.
  else do:
    assign
      cli-code           = buf_clients.obj-code
      cli-type           = buf_clients.obj-type
      cli-name           = buf_clients.obj-name
    .
  end.
  ENABLE transport-contract WITH FRAME Dialog-Frame.
  display cli-code cli-type cli-name  transport-contract FILL-cont  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME transport-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL transport-type Dialog-Frame
ON LEAVE OF transport-type IN FRAME Dialog-Frame /* Тип доставки */
DO:
  assign transport-type .
  find first buf_delivery-type no-lock where buf_delivery-type.deliv-type-code = transport-type no-error .
  if available buf_delivery-type then do:
    assign
      transport-type = buf_delivery-type.deliv-type-code
      FILL-type      = buf_delivery-type.deliv-type-name
    .
    display transport-type  FILL-type  with frame {&frame-name} .
  end.
  else apply "CHOOSE"  to BUTTON-type  IN FRAME Dialog-Frame .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL transport-type Dialog-Frame
ON RETURN OF transport-type IN FRAME Dialog-Frame /* Тип доставки */
DO:
  assign transport-type .
  find first buf_delivery-type no-lock where buf_delivery-type.deliv-type-code = transport-type no-error .
  if available buf_delivery-type then do:
    assign
      transport-type = buf_delivery-type.deliv-type-code
      FILL-type      = buf_delivery-type.deliv-type-name
    .
    display transport-type  FILL-type  with frame {&frame-name} .
  end.
  else apply "CHOOSE"  to BUTTON-type  IN FRAME Dialog-Frame .
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

  { gbl/getcntxt.i get }

  if p-type = "contract" then ASSIGN  frame {&frame-name}:TITLE = "Транспортные настройки договора" .

  COMBO-usl:list-items   = {&transport-include-full} + ","  + {&transport-prc-full} + ","  + {&transport-dist-full} .
  define buffer buf_clients for ub.clients.
  find first buf_clients no-lock where buf_clients.obj-type = p-transport-cli-type and buf_clients.obj-code = p-transport-cli-code no-error.
  if available buf_clients then assign cli-name = buf_clients.obj-name .
  define buffer buf_contract for ub.contract .
  find first buf_contract no-lock where buf_contract.host-code = p-transport-host and buf_contract.contract-code = p-transport-contract no-error.
  if available buf_contract then assign FILL-cont = buf_contract.contract-prn-code + " от " + string(contract-date,"99/99/9999") .

  case p-mode :
    when {&add-def} then do:
      assign COMBO-usl:screen-value   = {&transport-include-full} .
    end.
    when {&update} or when {&lookup} then do:
      assign
        cli-type           = p-transport-cli-type
        cli-code           = p-transport-cli-code
        transport-contract = p-transport-contract
        transport-type     = p-transport-type
      .
      if available buf_contract then assign v-transport-host = buf_contract.host-code .
      case p-transport-uslov :
        when int({&transport-include}) then assign COMBO-usl:screen-value   = {&transport-include-full} .
        when int({&transport-prc})     then
          assign
            COMBO-usl:screen-value   = {&transport-prc-full}
            transport-value = p-transport-value
          .
        when int({&transport-dist})    then assign COMBO-usl:screen-value   = {&transport-dist-full} .
      end.
      apply "LEAVE"  to transport-type  IN FRAME Dialog-Frame .
      apply "LEAVE"  to transport-contract  IN FRAME Dialog-Frame .
    end.
  end case.

  RUN Myenable_UI.
  apply "VALUE-CHANGED"  to COMBO-usl  IN FRAME Dialog-Frame .
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
PROCEDURE Myenable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY cli-code cli-type cli-name transport-contract FILL-cont
          transport-value COMBO-usl transport-type FILL-type
      WITH FRAME Dialog-Frame.

  ENABLE B-exit b-quit B-Help  WITH FRAME Dialog-Frame.
  if p-mode = {&add-def} or p-mode = {&update} then do:
    ENABLE cli-code cli-type BUTTON-cli cli-name
         transport-contract BUTTON-contr FILL-cont transport-value COMBO-usl
         transport-type BUTTON-type FILL-type
      WITH FRAME Dialog-Frame.
  end.
  else do:
    B-exit:label in frame {&frame-name} = "&Выход" .
    b-quit:visible = no .
  end.

  if p-type <> "contract" then do:
    assign
      transport-type:visible = no
      FILL-type:visible = no
      BUTTON-type:visible = no
    .
  end.

  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME