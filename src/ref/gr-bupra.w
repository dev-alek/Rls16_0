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

Добавление новой группы покупателей

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as handle no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter p-recid as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Добавление новой группы покупателей".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-save B-Help v-name v-oborot r-cli ~
v-gr v-gr-db-num v-gr-name
&Scoped-Define DISPLAYED-OBJECTS v-name v-oborot v-gr v-gr-db-num v-gr-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cli"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".

DEFINE VARIABLE v-gr AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL "Переходит в группу"
      VIEW-AS TEXT
     SIZE 11.5 BY .67 NO-UNDO.

DEFINE VARIABLE v-gr-db-num AS INTEGER FORMAT "(>>9)":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4 BY .67 NO-UNDO.

DEFINE VARIABLE v-gr-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 42 BY .67 NO-UNDO.

DEFINE VARIABLE v-name LIKE ub.buyer-group.name
     LABEL "Название группы покупателей"
     VIEW-AS FILL-IN
     SIZE 55 BY 1 NO-UNDO.

DEFINE VARIABLE v-oborot LIKE ub.buyer-group.oborot
     LABEL "Оборот для перехода в другую группу"
     VIEW-AS FILL-IN
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE v-rule-grp LIKE ub.buyer-group.rule-grp
     LABEL "Правило"
     VIEW-AS FILL-IN
     SIZE 26 BY 1 NO-UNDO.

DEFINE VARIABLE v-use-alg LIKE ub.buyer-group.use-alg
     LABEL "Работает алгоритм при переходе по группам"
     VIEW-AS TOGGLE-BOX
     SIZE 44.5 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 11
     B-save AT ROW 1 COL 1
     B-Help AT ROW 1 COL 77
     v-name AT ROW 2.75 COL 28 COLON-ALIGNED HELP
          ""
          LABEL "Название группы покупателей" FORMAT "X(80)"
     v-oborot AT ROW 4 COL 39 COLON-ALIGNED HELP
          ""
          LABEL "Оборот для перехода в другую группу" FORMAT "->>>,>>>,>>>,>>9.99"
     r-cli AT ROW 5.17 COL 39.5
     v-rule-grp AT ROW 8.25 COL 34.5 COLON-ALIGNED HELP
          ""
          LABEL "Правило" FORMAT "X(256)"
     v-use-alg AT ROW 9.5 COL 36.5 HELP
          ""
          LABEL "Работает алгоритм при переходе по группам"
     v-gr AT ROW 5.25 COL 20.5 COLON-ALIGNED
     v-gr-db-num AT ROW 5.25 COL 33.38 COLON-ALIGNED NO-LABEL
     v-gr-name AT ROW 5.25 COL 40.5 COLON-ALIGNED NO-LABEL
     SPACE(2.50) SKIP(6.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Добавление группы покупателей для ценообразования"
         DEFAULT-BUTTON B-save CANCEL-BUTTON B-Cancel.


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
       v-gr-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-name IN FRAME Dialog-Frame
   LIKE = ub.buyer-group.name EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE    */
/* SETTINGS FOR FILL-IN v-oborot IN FRAME Dialog-Frame
   LIKE = ub.buyer-group.oborot EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE  */
/* SETTINGS FOR FILL-IN v-rule-grp IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.buyer-group.rule-grp EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
ASSIGN
       v-rule-grp:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX v-use-alg IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.buyer-group.use-alg EXP-LABEL EXP-HELP EXP-SIZE */
ASSIGN
       v-use-alg:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Добавление группы покупателей для ценообразования */
DO:
  RUN save-proc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Добавление группы покупателей для ценообразования */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cli Dialog-Frame
ON CHOOSE OF r-cli IN FRAME Dialog-Frame /* r-cli */
DO:
  define variable v-recid as character no-undo .
  define buffer bf_buyer-group for ub.buyer-group  .
  run ref/gr-bupr.w  (parParentProc , "b-sel" , input-output  v-recid).
  find first bf_buyer-group no-lock where recid(bf_buyer-group) = int(v-recid)  no-error .
  if not available bf_buyer-group then do:
  display "" @ v-gr
          "" @ v-gr-db-num
          "" @ v-gr-name
          with frame {&frame-name} .

  return .
  end.
  assign
      v-gr        = bf_buyer-group.bgr-id
      v-gr-db-num = bf_buyer-group.bgr-db-num
      v-gr-name   = bf_buyer-group.name

  .

  display v-gr
          v-gr-db-num
          v-gr-name
          with frame {&frame-name} .


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
  run init-proc in this-procedure .
  run enable_ui in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS v-name.
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
  DISPLAY v-name v-oborot v-gr v-gr-db-num v-gr-name
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-save B-Help v-name v-oborot r-cli v-gr v-gr-db-num
         v-gr-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if p-mode = {&update} then do:
    find first  ub.buyer-group exclusive-lock where recid(ub.buyer-group) = p-recid no-error .
    if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          ""
          view-as alert-box error
        .
        return .
    end.
    assign
      v-name     =     ub.buyer-group.name
      v-oborot   =     ub.buyer-group.oborot
      v-rule-grp =     ub.buyer-group.rule-grp
      v-use-alg  =     ub.buyer-group.use-alg
      v-gr-db-num =    ub.buyer-group.gop-db-num
      v-gr        =    ub.buyer-group.gop-id
    .
define buffer bf_buyer-group for ub.buyer-group  .
display v-name
        v-oborot
        /* v-rule-grp
        v-use-alg
        */
        v-gr-db-num
        v-gr
        with frame {&frame-name} .

find first bf_buyer-group no-lock where
            bf_buyer-group.bgr-id       = v-gr and
            bf_buyer-group.bgr-db-num   = v-gr-db-num
            no-error .

if available bf_buyer-group then do:
assign
    v-gr-name   = bf_buyer-group.name
.
display v-gr-db-num
        v-gr-name
        v-gr
        with frame {&frame-name} .

  end.
  end.
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

ASSIGN frame {&frame-name}
        v-name
        v-oborot
        v-rule-grp
        v-use-alg
        v-gr
        v-gr-db-num
        .
if p-mode = {&add-def} then do:
create ub.buyer-group.
assign
  ub.buyer-group.bgr-db-num   = v-cntxt-db-num
  ub.buyer-group.bgr-id       = next-value ( s-bgr , {&db-name_schema} )
  ub.buyer-group.db-num-chg   = v-cntxt-db-num
  ub.buyer-group.gop-db-num   = v-cntxt-db-num
  ub.buyer-group.gop-id       = 0
  ub.buyer-group.stts         = 0

  ub.buyer-group.name       = v-name
  ub.buyer-group.oborot     = v-oborot
  ub.buyer-group.gop-id     = v-gr
  ub.buyer-group.gop-db-num = v-gr-db-num
  ub.buyer-group.use-alg    = v-use-alg
  p-recid = recid(ub.buyer-group)
.
end.
else do:
assign
  ub.buyer-group.db-num-chg   = v-cntxt-db-num
  ub.buyer-group.stts         = 0
  ub.buyer-group.name       = v-name
  ub.buyer-group.oborot     = v-oborot
  ub.buyer-group.gop-id     = v-gr
  ub.buyer-group.gop-db-num = v-gr-db-num
  ub.buyer-group.use-alg    = v-use-alg
  p-recid = recid(ub.buyer-group)
.

end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME