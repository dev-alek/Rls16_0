&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

СПисок профайлов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/05/06
Author: Bakhtadze Natalya
Creation date: 03/05/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-bttns as character no-undo .
define input parameter p-list-mode as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-ref-list AS CHARACTER NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список частных итогов для типов ДК".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i DEF }
{ gbl/color.i }
DEFINE VARIABLE ri AS RECID NO-UNDO.
define variable v-ref-list as character no-undo .
define variable v-obj-mode as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-rule-profile

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES FIRST

/* Definitions for BROWSE br-rule-profile                                       */
&Scoped-define FIELDS-IN-QUERY-br-rule-profile (IF ( CAN-DO (v-ref-list, string( recid( X_rule-profile ) ) ) ) THEN ("*") ELSE (" ")) X_rule-profile.name X_rule-profile.profile_id X_rule-profile.IS_dynamic
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rule-profile
&Scoped-define SELF-NAME br-rule-profile
&Scoped-define QUERY-STRING-br-rule-profile FOR EACH FIRST X_rule-profile NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-rule-profile OPEN QUERY {&SELF-NAME} FOR EACH X_rule-profile NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-rule-profile FIRST
&Scoped-define FIRST-TABLE-IN-QUERY-br-rule-profile FIRST


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-rule-profile}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-quit B-mark B-sel b-lkp B-Help br-rule-profile ~
mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9.9 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-rule-profile FOR X_rule-profile
       SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-rule-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rule-profile Dialog-Frame _FREEFORM
  QUERY br-rule-profile NO-LOCK DISPLAY
      (IF ( CAN-DO (v-ref-list, string( recid( X_rule-profile ) ) ) ) THEN ("*") ELSE (" ")) COLUMN-LABEL "*" FORMAT "x(1)":U
X_rule-profile.name COLUMN-LABEL "Название" FORMAT "X(85)":U
X_rule-profile.profile_id COLUMN-LABEL "Код" FORMAT ">>9":U
X_rule-profile.IS_dynamic COLUMN-LABEL "Отклю!чаемый" FORMAT "+/"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 14
     b-lkp AT ROW 1 COL 41 WIDGET-ID 2
     B-Help AT ROW 1 COL 95
     br-rule-profile AT ROW 3 COL 1
     mark-num AT ROW 2 COL 2.9 NO-LABEL
     SPACE(86.82) SKIP(16.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_rule-profile B "?" ? ub rule-profile
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-rule-profile B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rule-profile
/* Query rebuild information for BROWSE br-rule-profile
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH FIRST X_rule-profile NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-rule-profile */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  p-ref-list = v-ref-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  DEFINE VARIABLE v-rec AS RECID NO-UNDO.
  IF NOT AVAILABLE X_rule-profile THEN RETURN NO-APPLY.
  v-rec = recid(X_rule-profile).
  run rul/rule-profile-i.w ( input parparentproc
                       ,input {&lookup}
                       ,input X_rule-profile.profile_id
                       ,input-output v-rec) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
DEFINE VARIABLE loc#log as logical no-undo.
if available X_rule-profile then do:
  { gbl/markstrn.i X_rule-profile v-ref-list }
  loc#log = br-rule-profile:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      loc#log = br-rule-profile:select-next-row ().
      apply "iteration-changed" to br-rule-profile in frame {&frame-name}.
  end.
  if num-entries( v-ref-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-ref-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-rule-profile in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
if available X_rule-profile and
(v-ref-list = ""
or b-mark:sensitive = no)
then do:
    v-ref-list = string(recid( X_rule-profile)).
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rule-profile
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

ON ROW-DISPLAY OF br-rule-profile IN frame {&frame-name}
DO:
  IF AVAIL X_rule-profile THEN DO:
    RUN set-row-color IN THIS-PROCEDURE ( INPUT X_rule-profile.parent-feature).
  END.
END.


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-lkp }

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/brwrefre.i

  " if available X_rule-profile then ri = recid(X_rule-profile). ~
    RUn OpenBr in this-procedure . ~
    reposition br-rule-profile to recid ri no-error. "
}




/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
 if num-entries(p-list-mode, {&delim-par}) > 1 then do:
   v-obj-mode = entry(2, p-list-mode, {&delim-par}) = {&shop}
               or
               entry(2, p-list-mode, {&delim-par}) = {&stock}.
   p-list-mode = entry(1, p-list-mode, {&delim-par} ).
 end.
 IF LOOKUP(p-list-mode, {&profile-type-list}) = 0 THEN DO:
   message
   vss-workfile vss-revision vss-description skip
   "Неверный параметр вызова p-list-mode" p-list-mode
    view-as alert-box ERROR.
    return error.
  END.
  v-ref-list = p-ref-list.
  run Myenable IN THIS-PROCEDURE .
  run openbr IN THIS-PROCEDURE.
    if num-entries (v-ref-list) = 0 then
        hide mark-num in frame {&frame-name}.
    else
        disp
        num-entries (v-ref-list) @ mark-num
        with frame {&frame-name}.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure.

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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE B-quit B-mark B-sel b-lkp B-Help br-rule-profile mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE ch AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE ii AS integer NO-UNDO.
assign
X_rule-profile.name:resizable in browse br-rule-profile = yes.
&scop profile-type-code p-list-mode

FRAME {&FRAME-NAME}:TITLE = substitute("Профайлы с типом: &1", {&profile-type-name}).
DISPLAY mark-num
WITH FRAME {&frame-name}.
ENABLE
B-quit
B-mark WHEN lookup('b-mark', p-bttns) > 0
B-sel WHEN lookup('b-sel', p-bttns) > 0
b-lkp
B-Help
br-rule-profile
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
if v-obj-mode then do:
OPEN QUERY br-rule-profile
FOR EACH X_rule-profile where
        X_rule-profile.profile-type = p-list-mode
     and  lookup("obj", X_rule-profile.short-name)  > 0
by X_rule-profile.profile_id.

end.
else do:
  OPEN QUERY br-rule-profile
  FOR EACH X_rule-profile where
          X_rule-profile.profile-type = p-list-mode
  by X_rule-profile.profile_id.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color Dialog-Frame
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-parent-feature AS integer NO-UNDO.
if p-parent-feature = integer({&rp-parentf-only-in-combo}) then do:
  assign
  X_rule-profile.name:BGCOLOR IN BROWSE {&BROWSE-NAME} = GRAY_COLOR
    .
end.
else do:
  assign
  X_rule-profile.name:BGCOLOR IN BROWSE {&BROWSE-NAME} = ?
    .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
